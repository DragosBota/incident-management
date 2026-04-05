class IncidentLog {
  final String id;
  final String incidentId;
  final String actionType;
  final String description;
  final String? oldStatus;
  final String? newStatus;
  final String createdBy;
  final DateTime createdAt;

  IncidentLog({
    required this.id,
    required this.incidentId,
    required this.actionType,
    required this.description,
    this.oldStatus,
    this.newStatus,
    required this.createdBy,
    required this.createdAt,
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
    );
  }
}