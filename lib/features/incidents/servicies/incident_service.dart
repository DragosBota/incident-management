import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/services/supabase_service.dart';
import '../models/incident.dart';
import '../models/incident_log.dart';
import '../models/incident_status.dart';

class IncidentService {
  final SupabaseClient _client = SupabaseService.client;

  Future<List<Incident>> fetchIncidents() async {
    final response = await _client
        .from('incidents')
        .select()
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response)
        .map((map) => Incident.fromMap(map))
        .toList();
  }

  Future<Incident> fetchIncidentById(String id) async {
    final response = await _client
        .from('incidents')
        .select()
        .eq('id', id)
        .single();

    return Incident.fromMap(response);
  }

  Future<List<IncidentLog>> fetchIncidentLogs(String incidentId) async {
    final response = await _client
        .from('incident_logs')
        .select()
        .eq('incident_id', incidentId)
        .order('created_at', ascending: true);

    return List<Map<String, dynamic>>.from(response)
        .map((map) => IncidentLog.fromMap(map))
        .toList();
  }

  Future<String> _generateIncidentCode() async {
    final now = DateTime.now();

    final year = (now.year % 100).toString().padLeft(2, '0');
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');

    final datePrefix = '$year$month$day';

    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final response = await _client
        .from('incidents')
        .select('id')
        .gte('created_at', startOfDay.toString())
        .lt('created_at', endOfDay.toString());

    final countToday = List<Map<String, dynamic>>.from(response).length;
    final sequence = (countToday + 1).toString().padLeft(2, '0');

    return '$datePrefix-$sequence';
  }

  Future<void> _createIncidentLog({
    required String incidentId,
    required String actionType,
    required String description,
    String? oldStatus,
    String? newStatus,
    required String createdBy,
  }) async {
    await _client.from('incident_logs').insert({
      'incident_id': incidentId,
      'action_type': actionType,
      'description': description,
      'old_status': oldStatus,
      'new_status': newStatus,
      'created_by': createdBy,
    });
  }

  Future<void> createIncident({
    required String customerName,
    required String sapOrder,
    required String description,
    required String createdBy,
    required String departmentAt,
  }) async {
    final incidentCode = await _generateIncidentCode();

    final incidentResponse = await _client
        .from('incidents')
        .insert({
          'incident_code': incidentCode,
          'customer_name': customerName,
          'sap_order': sapOrder,
          'description': description,
          'status': IncidentStatus.registered,
          'department_at': departmentAt,
          'resolution_type': null,
          'created_by': createdBy,
          'sync_status': 'SYNCED',
        })
        .select()
        .single();

    final incidentId = incidentResponse['id'] as String;

    await _createIncidentLog(
      incidentId: incidentId,
      actionType: 'CREATE',
      description: 'Incident created',
      oldStatus: null,
      newStatus: 'REGISTERED',
      createdBy: createdBy,
    );
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

  await _client
      .from('incidents')
      .update({
        'status': newStatus,
        'department_at': newDepartmentId,
        'updated_at': DateTime.now().toString(),
      })
      .eq('id', incidentId);

    await _createIncidentLog(
      incidentId: incidentId,
      actionType: 'STATUS_CHANGE',
      description: 'Status changed from $oldStatus to $newStatus',
      oldStatus: oldStatus,
      newStatus: newStatus,
      createdBy: userId,
    );
  }

    Future<void> updateIncident({
      required String incidentId,
      required String customerName,
      required String sapOrder,
      required String description,
      required String userId,
    }) async {
      final current = await _client
          .from('incidents')
          .select()
          .eq('id', incidentId)
          .single();

      final oldCustomer = current['customer_name'] as String;
      final oldSapOrder = current['sap_order'] as String;
      final oldDescription = current['description'] as String;

      await _client
          .from('incidents')
          .update({
            'customer_name': customerName,
            'sap_order': sapOrder,
            'description': description,
            'updated_at': DateTime.now().toString(),
          })
          .eq('id', incidentId);

      if (oldCustomer != customerName) {
        await _createIncidentLog(
          incidentId: incidentId,
          actionType: 'UPDATE',
          description:
              'Customer changed from "$oldCustomer" to "$customerName"',
          createdBy: userId,
        );
      }

      if (oldSapOrder != sapOrder) {
        await _createIncidentLog(
          incidentId: incidentId,
          actionType: 'UPDATE',
          description:
              'SAP Order changed from "$oldSapOrder" to "$sapOrder"',
          createdBy: userId,
        );
      }

      if (oldDescription != description) {
        await _createIncidentLog(
          incidentId: incidentId,
          actionType: 'UPDATE',
          description: 'Description updated',
          createdBy: userId,
        );
      }
    }

  Future<void> softDeleteIncident({
  required String incidentId,
  required String reason,
  required String userId,
  }) async {
    await _client
        .from('incidents')
        .update({
          'deleted_at': DateTime.now().toString(),
          'deleted_reason': reason,
          'deleted_by': userId,
          'updated_at': DateTime.now().toString(),
        })
        .eq('id', incidentId);

    await _createIncidentLog(
      incidentId: incidentId,
      actionType: 'DELETE',
      description: 'Incident soft deleted. Reason: $reason',
      createdBy: userId,
    );
  }
}
