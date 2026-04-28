import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../shared/services/supabase_service.dart';
import '../models/incident.dart';
import '../models/incident_log.dart';
import 'incident_local_service.dart';
import 'incident_log_local_service.dart';

class IncidentSyncService {
  IncidentSyncService();

  final SupabaseClient _client = SupabaseService.client;
  final IncidentLocalService _incidentLocalService = IncidentLocalService();
  final IncidentLogLocalService _incidentLogLocalService =
      IncidentLogLocalService();

  Future<void> syncPendingChanges() async {
    await _syncPendingIncidents();
    await _syncPendingLogs();
  }

  Future<void> _syncPendingIncidents() async {
    final pendingIncidents = await _incidentLocalService.fetchPendingIncidents();

    for (final incident in pendingIncidents) {
      try {
        switch (incident.syncStatus) {
          case 'PENDING_CREATE':
            await _createRemoteIncident(incident);
            await _incidentLocalService.updateIncidentSyncStatus(
              incidentId: incident.id,
              syncStatus: 'SYNCED',
            );
            break;
          case 'PENDING_UPDATE':
            await _updateRemoteIncident(incident);
            await _incidentLocalService.updateIncidentSyncStatus(
              incidentId: incident.id,
              syncStatus: 'SYNCED',
            );
            break;
          case 'PENDING_DELETE':
            await _deleteRemoteIncident(incident);
            await _incidentLocalService.updateIncidentSyncStatus(
              incidentId: incident.id,
              syncStatus: 'SYNCED',
            );
            break;
        }
      } catch (_) {
        // If syncing one record fails, keep it pending and continue.
      }
    }
  }

  Future<void> _syncPendingLogs() async {
    final pendingLogs = await _incidentLogLocalService.fetchPendingIncidentLogs();

    for (final log in pendingLogs) {
      try {
        await _createRemoteIncidentLog(log);
        await _incidentLogLocalService.updateIncidentLogSyncStatus(
          logId: log.id,
          syncStatus: 'SYNCED',
        );
      } catch (_) {
        // If syncing one record fails, keep it pending and continue.
      }
    }
  }

  Future<void> _createRemoteIncident(Incident incident) async {
    await _client.from('incidents').upsert({
      ...incident.toMap(),
      'sync_status': 'SYNCED',
    });
  }

  Future<void> _updateRemoteIncident(Incident incident) async {
    await _client
        .from('incidents')
        .update({
          ...incident.toMap(),
          'sync_status': 'SYNCED',
        })
        .eq('id', incident.id);
  }

  Future<void> _deleteRemoteIncident(Incident incident) async {
    final deletedAt = incident.deletedAt?.toIso8601String() ??
        DateTime.now().toIso8601String();

    await _client
        .from('incidents')
        .update({
          'deleted_at': deletedAt,
          'deleted_reason': incident.deletedReason,
          'deleted_by': incident.deletedBy,
          'updated_at': incident.updatedAt.toIso8601String(),
          'sync_status': 'SYNCED',
        })
        .eq('id', incident.id);
  }

  Future<void> _createRemoteIncidentLog(IncidentLog log) async {
    await _client.from('incident_logs').upsert({
      'id': log.id,
      'incident_id': log.incidentId,
      'action_type': log.actionType,
      'description': log.description,
      'old_status': log.oldStatus,
      'new_status': log.newStatus,
      'created_by': log.createdBy,
      'created_at': log.createdAt.toIso8601String(),
    });
  }
}
