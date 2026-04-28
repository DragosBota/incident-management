import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../shared/services/supabase_service.dart';
import '../models/incident.dart';
import '../models/incident_list_filter.dart';
import '../models/incident_log.dart';
import '../models/incident_status.dart';
import 'incident_log_local_service.dart';
import 'incident_local_service.dart';
import 'incident_sync_service.dart';

class IncidentService {
  IncidentService();

  final SupabaseClient _client = SupabaseService.client;
  final IncidentLocalService _localService = IncidentLocalService();
  final IncidentLogLocalService _logLocalService = IncidentLogLocalService();
  final IncidentSyncService _syncService = IncidentSyncService();
  final Uuid _uuid = const Uuid();

  Future<void> syncPendingChanges() async {
    await _syncService.syncPendingChanges();
  }

  Future<List<Incident>> fetchIncidents({
    IncidentListFilter filter = IncidentListFilter.opened,
  }) async {
    try {
      await _syncService.syncPendingChanges();
      final remoteIncidents = await _fetchRemoteIncidents();
      await _localService.saveIncidents(remoteIncidents);
    } catch (_) {
      // If remote access fails, the app falls back to the local cache.
    }

    return _localService.fetchIncidents(filter: filter);
  }

  Future<Incident> fetchIncidentById(String id) async {
    try {
      await _syncService.syncPendingChanges();
      final remoteIncident = await _fetchRemoteIncidentById(id);
      await _localService.saveIncidents([remoteIncident]);
    } catch (_) {
      // If remote access fails, the app falls back to the local cache.
    }

    final localIncident = await _localService.fetchIncidentById(id);

    if (localIncident != null) {
      return localIncident;
    }

    throw Exception('Incident not found');
  }

  Future<List<IncidentLog>> fetchIncidentLogs(String incidentId) async {
    try {
      await _syncService.syncPendingChanges();
      final remoteLogs = await _fetchRemoteIncidentLogs(incidentId);
      await _logLocalService.saveIncidentLogs(remoteLogs);
    } catch (_) {
      // If remote access fails, the app falls back to the local cache.
    }

    return _logLocalService.fetchIncidentLogs(incidentId);
  }

  Future<String> _generateIncidentCode() async {
    final now = DateTime.now();
    final year = (now.year % 100).toString().padLeft(2, '0');
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    final datePrefix = '$year$month$day';

    final countToday = await _localService.countIncidentsForDate(now);
    final sequence = (countToday + 1).toString().padLeft(2, '0');

    return '$datePrefix-$sequence';
  }

  Future<List<Incident>> _fetchRemoteIncidents() async {
    final response = await _client
        .from('incidents')
        .select()
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response)
        .map((map) => Incident.fromMap(map))
        .toList();
  }

  Future<Incident> _fetchRemoteIncidentById(String id) async {
    final response = await _client
        .from('incidents')
        .select()
        .eq('id', id)
        .single();

    return Incident.fromMap(response);
  }

  Future<List<IncidentLog>> _fetchRemoteIncidentLogs(String incidentId) async {
    final response = await _client
        .from('incident_logs')
        .select()
        .eq('incident_id', incidentId)
        .order('created_at', ascending: true);

    return List<Map<String, dynamic>>.from(response)
        .map((map) => IncidentLog.fromMap(map))
        .toList();
  }

  Future<IncidentLog> _buildIncidentLog({
    required String incidentId,
    required String actionType,
    required String description,
    String? oldStatus,
    String? newStatus,
    required String createdBy,
    required String syncStatus,
  }) async {
    return IncidentLog(
      id: _uuid.v4(),
      incidentId: incidentId,
      actionType: actionType,
      description: description,
      oldStatus: oldStatus,
      newStatus: newStatus,
      createdBy: createdBy,
      createdAt: DateTime.now(),
      syncStatus: syncStatus,
    );
  }

  Future<void> _createIncidentLog({
    required String incidentId,
    required String actionType,
    required String description,
    String? oldStatus,
    String? newStatus,
    required String createdBy,
  }) async {
    final log = await _buildIncidentLog(
      incidentId: incidentId,
      actionType: actionType,
      description: description,
      oldStatus: oldStatus,
      newStatus: newStatus,
      createdBy: createdBy,
      syncStatus: 'PENDING_CREATE',
    );

    await _logLocalService.insertIncidentLog(log);

    try {
      await _client.from('incident_logs').insert({
        'id': log.id,
        'incident_id': log.incidentId,
        'action_type': log.actionType,
        'description': log.description,
        'old_status': log.oldStatus,
        'new_status': log.newStatus,
        'created_by': log.createdBy,
        'created_at': log.createdAt.toIso8601String(),
      });

      await _logLocalService.updateIncidentLogSyncStatus(
        logId: log.id,
        syncStatus: 'SYNCED',
      );
    } catch (_) {
      // The log remains stored locally until full sync is implemented.
    }
  }

  Future<void> _createRemoteIncident(Incident incident) async {
    await _client.from('incidents').insert({
      ...incident.toMap(),
      'sync_status': 'SYNCED',
    });

    await _createIncidentLog(
      incidentId: incident.id,
      actionType: 'CREATE',
      description: 'Incident created',
      oldStatus: null,
      newStatus: IncidentStatus.registered,
      createdBy: incident.createdBy,
    );
  }

  Future<void> createIncident({
    required String customerName,
    required String sapOrder,
    required String description,
    required String createdBy,
    required String departmentAt,
  }) async {
    final now = DateTime.now();
    final incident = Incident(
      id: _uuid.v4(),
      incidentCode: await _generateIncidentCode(),
      customerName: customerName,
      sapOrder: sapOrder,
      description: description,
      status: IncidentStatus.registered,
      departmentAt: departmentAt,
      resolutionType: null,
      createdBy: createdBy,
      createdAt: now,
      updatedAt: now,
      syncStatus: 'PENDING_CREATE',
      deletedAt: null,
      deletedReason: null,
      deletedBy: null,
    );

    await _localService.insertIncident(incident);

    try {
      await _createRemoteIncident(incident);

      await _localService.updateIncident(
        incident.copyWith(syncStatus: 'SYNCED'),
      );
    } catch (_) {
      // The incident remains stored locally and can be synced later.
    }
  }

  Future<void> _updateRemoteIncidentFields({
    required String incidentId,
    required Map<String, dynamic> fields,
  }) async {
    await _client
        .from('incidents')
        .update({
          ...fields,
          'sync_status': 'SYNCED',
        })
        .eq('id', incidentId);
  }

  Future<void> updateIncidentStatus({
    required String incidentId,
    required String oldStatus,
    required String newStatus,
    required String newDepartmentId,
    required String userId,
  }) async {
    if (!IncidentStatus.values.contains(newStatus)) {
      throw Exception('Invalid incident status: $newStatus');
    }

    final currentIncident = await fetchIncidentById(incidentId);
    final updatedIncident = currentIncident.copyWith(
      status: newStatus,
      departmentAt: newDepartmentId,
      updatedAt: DateTime.now(),
      syncStatus: 'PENDING_UPDATE',
    );

    await _localService.updateIncident(updatedIncident);

    try {
      await _updateRemoteIncidentFields(
        incidentId: incidentId,
        fields: {
          'status': newStatus,
          'department_at': newDepartmentId,
          'updated_at': updatedIncident.updatedAt.toIso8601String(),
        },
      );

      await _createIncidentLog(
        incidentId: incidentId,
        actionType: 'STATUS_CHANGE',
        description: 'Status changed from $oldStatus to $newStatus',
        oldStatus: oldStatus,
        newStatus: newStatus,
        createdBy: userId,
      );

      await _localService.updateIncident(
        updatedIncident.copyWith(syncStatus: 'SYNCED'),
      );
    } catch (_) {
      // The change remains pending locally until full sync is implemented.
    }
  }

  Future<void> updateIncident({
    required String incidentId,
    required String customerName,
    required String sapOrder,
    required String description,
    required String userId,
  }) async {
    final currentIncident = await fetchIncidentById(incidentId);
    final updatedIncident = currentIncident.copyWith(
      customerName: customerName,
      sapOrder: sapOrder,
      description: description,
      updatedAt: DateTime.now(),
      syncStatus: 'PENDING_UPDATE',
    );

    await _localService.updateIncident(updatedIncident);

    try {
      await _updateRemoteIncidentFields(
        incidentId: incidentId,
        fields: {
          'customer_name': customerName,
          'sap_order': sapOrder,
          'description': description,
          'updated_at': updatedIncident.updatedAt.toIso8601String(),
        },
      );

      if (currentIncident.customerName != customerName) {
        await _createIncidentLog(
          incidentId: incidentId,
          actionType: 'UPDATE',
          description:
              'Customer changed from "${currentIncident.customerName}" to "$customerName"',
          createdBy: userId,
        );
      }

      if (currentIncident.sapOrder != sapOrder) {
        await _createIncidentLog(
          incidentId: incidentId,
          actionType: 'UPDATE',
          description:
              'SAP Order changed from "${currentIncident.sapOrder}" to "$sapOrder"',
          createdBy: userId,
        );
      }

      if (currentIncident.description != description) {
        await _createIncidentLog(
          incidentId: incidentId,
          actionType: 'UPDATE',
          description: 'Description updated',
          createdBy: userId,
        );
      }

      await _localService.updateIncident(
        updatedIncident.copyWith(syncStatus: 'SYNCED'),
      );
    } catch (_) {
      // The change remains pending locally until full sync is implemented.
    }
  }

  Future<void> softDeleteIncident({
    required String incidentId,
    required String reason,
    required String userId,
  }) async {
    final currentIncident = await fetchIncidentById(incidentId);
    final now = DateTime.now();
    final deletedIncident = currentIncident.copyWith(
      updatedAt: now,
      deletedAt: now,
      deletedReason: reason,
      deletedBy: userId,
      syncStatus: 'PENDING_DELETE',
    );

    await _localService.updateIncident(deletedIncident);

    try {
      await _updateRemoteIncidentFields(
        incidentId: incidentId,
        fields: {
          'deleted_at': now.toIso8601String(),
          'deleted_reason': reason,
          'deleted_by': userId,
          'updated_at': now.toIso8601String(),
        },
      );

      await _createIncidentLog(
        incidentId: incidentId,
        actionType: 'DELETE',
        description: 'Incident soft deleted. Reason: $reason',
        createdBy: userId,
      );

      await _localService.updateIncident(
        deletedIncident.copyWith(syncStatus: 'SYNCED'),
      );
    } catch (_) {
      // The change remains pending locally until full sync is implemented.
    }
  }
}
