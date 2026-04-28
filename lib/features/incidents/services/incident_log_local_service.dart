import 'package:sqflite/sqflite.dart';

import '../../../shared/services/local_database_service.dart';
import '../models/incident_log.dart';

class IncidentLogLocalService {
  IncidentLogLocalService({LocalDatabaseService? localDatabaseService})
      : _localDatabaseService =
            localDatabaseService ?? LocalDatabaseService.instance;

  final LocalDatabaseService _localDatabaseService;

  Future<List<IncidentLog>> fetchIncidentLogs(String incidentId) async {
    final db = await _localDatabaseService.database;

    final response = await db.query(
      'incident_logs',
      where: 'incident_id = ?',
      whereArgs: [incidentId],
      orderBy: 'created_at ASC',
    );

    return response
        .map((map) => IncidentLog.fromMap(Map<String, dynamic>.from(map)))
        .toList();
  }

  Future<void> saveIncidentLogs(List<IncidentLog> logs) async {
    final db = await _localDatabaseService.database;
    final batch = db.batch();

    for (final log in logs) {
      batch.insert(
        'incident_logs',
        log.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<void> insertIncidentLog(IncidentLog log) async {
    final db = await _localDatabaseService.database;

    await db.insert(
      'incident_logs',
      log.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<IncidentLog>> fetchPendingIncidentLogs() async {
    final db = await _localDatabaseService.database;

    final response = await db.query(
      'incident_logs',
      where: 'sync_status != ?',
      whereArgs: ['SYNCED'],
      orderBy: 'created_at ASC',
    );

    return response
        .map((map) => IncidentLog.fromMap(Map<String, dynamic>.from(map)))
        .toList();
  }

  Future<void> updateIncidentLogSyncStatus({
    required String logId,
    required String syncStatus,
  }) async {
    final db = await _localDatabaseService.database;

    await db.update(
      'incident_logs',
      {'sync_status': syncStatus},
      where: 'id = ?',
      whereArgs: [logId],
    );
  }
}
