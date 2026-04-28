class IncidentLog {
  final String id;
  final String incidentId;
  final String actionType;
  final String description;
  final String? oldStatus;
  final String? newStatus;
  final String createdBy;
  final DateTime createdAt;
  final String syncStatus;

  IncidentLog({
    required this.id,
    required this.incidentId,
    required this.actionType,
    required this.description,
    this.oldStatus,
    this.newStatus,
    required this.createdBy,
    required this.createdAt,
    required this.syncStatus,
  });

  factory IncidentLog.fromMap(Map<String, dynamic> map) {
    return IncidentLog(
      id: map['id'] as String,
      incidentId: map['incident_id'] as String,
      actionType: map['action_type'] as String,
      description: map['description'] as String,
      oldStatus: map['old_status'] as String?,
      newStatus: map['new_status'] as String?,
      createdBy: map['created_by'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      syncStatus: (map['sync_status'] as String?) ?? 'SYNCED',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'incident_id': incidentId,
      'action_type': actionType,
      'description': description,
      'old_status': oldStatus,
      'new_status': newStatus,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'sync_status': syncStatus,
    };
  }
}
