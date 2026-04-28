import 'package:sqflite/sqflite.dart';

import '../../../shared/services/local_database_service.dart';
import '../models/incident.dart';
import '../models/incident_list_filter.dart';

class IncidentLocalService {
  IncidentLocalService({LocalDatabaseService? localDatabaseService})
      : _localDatabaseService =
            localDatabaseService ?? LocalDatabaseService.instance;

  final LocalDatabaseService _localDatabaseService;

  Future<List<Incident>> fetchIncidents({
    IncidentListFilter filter = IncidentListFilter.opened,
  }) async {
    final db = await _localDatabaseService.database;
    final whereClause = _buildFilterWhereClause(filter);

    final response = await db.query(
      'incidents',
      where: whereClause.$1,
      whereArgs: whereClause.$2,
      orderBy: 'created_at DESC',
    );

    return response
        .map((map) => Incident.fromMap(Map<String, dynamic>.from(map)))
        .toList();
  }

  (String?, List<Object?>?) _buildFilterWhereClause(IncidentListFilter filter) {
    switch (filter) {
      case IncidentListFilter.opened:
        return (
          'deleted_at IS NULL AND status != ?',
          ['CLOSED'],
        );
      case IncidentListFilter.closed:
        return (
          'deleted_at IS NULL AND status = ?',
          ['CLOSED'],
        );
      case IncidentListFilter.deleted:
        return (
          'deleted_at IS NOT NULL',
          null,
        );
    }
  }

  Future<Incident?> fetchIncidentById(String id) async {
    final db = await _localDatabaseService.database;

    final response = await db.query(
      'incidents',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (response.isEmpty) {
      return null;
    }

    return Incident.fromMap(Map<String, dynamic>.from(response.first));
  }

  Future<void> saveIncidents(List<Incident> incidents) async {
    final db = await _localDatabaseService.database;
    final batch = db.batch();

    for (final incident in incidents) {
      final existing = await db.query(
        'incidents',
        columns: ['sync_status'],
        where: 'id = ?',
        whereArgs: [incident.id],
        limit: 1,
      );

      if (existing.isNotEmpty) {
        final syncStatus = existing.first['sync_status'] as String?;

        if (syncStatus != null && syncStatus != 'SYNCED') {
          continue;
        }
      }

      batch.insert(
        'incidents',
        incident.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<void> insertIncident(Incident incident) async {
    final db = await _localDatabaseService.database;

    await db.insert(
      'incidents',
      incident.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateIncident(Incident incident) async {
    final db = await _localDatabaseService.database;

    await db.update(
      'incidents',
      incident.toMap(),
      where: 'id = ?',
      whereArgs: [incident.id],
    );
  }

  Future<List<Incident>> fetchPendingIncidents() async {
    final db = await _localDatabaseService.database;

    final response = await db.query(
      'incidents',
      where: 'sync_status != ?',
      whereArgs: ['SYNCED'],
      orderBy: 'created_at ASC',
    );

    return response
        .map((map) => Incident.fromMap(Map<String, dynamic>.from(map)))
        .toList();
  }

  Future<void> updateIncidentSyncStatus({
    required String incidentId,
    required String syncStatus,
  }) async {
    final db = await _localDatabaseService.database;

    await db.update(
      'incidents',
      {'sync_status': syncStatus},
      where: 'id = ?',
      whereArgs: [incidentId],
    );
  }

  Future<int> countIncidentsForDate(DateTime date) async {
    final db = await _localDatabaseService.database;

    final startOfDay = DateTime(date.year, date.month, date.day)
        .toIso8601String();
    final endOfDay = DateTime(date.year, date.month, date.day + 1)
        .toIso8601String();

    final response = await db.rawQuery(
      '''
      SELECT COUNT(*) AS count
      FROM incidents
      WHERE created_at >= ? AND created_at < ?
      ''',
      [startOfDay, endOfDay],
    );

    return Sqflite.firstIntValue(response) ?? 0;
  }

  Future<void> softDeleteIncident({
    required String incidentId,
    required String reason,
    required String userId,
  }) async {
    final db = await _localDatabaseService.database;

    final now = DateTime.now().toIso8601String();

    await db.update(
      'incidents',
      {
        'deleted_at': now,
        'deleted_reason': reason,
        'deleted_by': userId,
        'updated_at': now,
      },
      where: 'id = ?',
      whereArgs: [incidentId],
    );
  }
}
