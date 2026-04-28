class Incident {
  final String id;
  final String incidentCode;
  final String customerName;
  final String sapOrder;
  final String description;
  final String status;
  final String departmentAt;
  final String? resolutionType;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncStatus;
  final DateTime? deletedAt;
  final String? deletedReason;
  final String? deletedBy;

  Incident({
    required this.id,
    required this.incidentCode,
    required this.customerName,
    required this.sapOrder,
    required this.description,
    required this.status,
    required this.departmentAt,
    this.resolutionType,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    this.deletedAt,
    this.deletedReason,
    this.deletedBy,
  });

  factory Incident.fromMap(Map<String, dynamic> map) {
    return Incident(
      id: map['id'] as String,
      incidentCode: map['incident_code'] as String,
      customerName: map['customer_name'] as String,
      sapOrder: map['sap_order'] as String,
      description: map['description'] as String,
      status: map['status'] as String,
      departmentAt: map['department_at'] as String,
      resolutionType: map['resolution_type'] as String?,
      createdBy: map['created_by'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      syncStatus: map['sync_status'] as String,
      deletedAt: map['deleted_at'] != null
          ? DateTime.parse(map['deleted_at'] as String)
          : null,
      deletedReason: map['deleted_reason'] as String?,
      deletedBy: map['deleted_by'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'incident_code': incidentCode,
      'customer_name': customerName,
      'sap_order': sapOrder,
      'description': description,
      'status': status,
      'department_at': departmentAt,
      'resolution_type': resolutionType,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'sync_status': syncStatus,
      'deleted_at': deletedAt?.toIso8601String(),
      'deleted_reason': deletedReason,
      'deleted_by': deletedBy,
    };
  }

  Incident copyWith({
    String? id,
    String? incidentCode,
    String? customerName,
    String? sapOrder,
    String? description,
    String? status,
    String? departmentAt,
    Object? resolutionType = _unset,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncStatus,
    Object? deletedAt = _unset,
    Object? deletedReason = _unset,
    Object? deletedBy = _unset,
  }) {
    return Incident(
      id: id ?? this.id,
      incidentCode: incidentCode ?? this.incidentCode,
      customerName: customerName ?? this.customerName,
      sapOrder: sapOrder ?? this.sapOrder,
      description: description ?? this.description,
      status: status ?? this.status,
      departmentAt: departmentAt ?? this.departmentAt,
      resolutionType: resolutionType == _unset
          ? this.resolutionType
          : resolutionType as String?,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      deletedAt: deletedAt == _unset ? this.deletedAt : deletedAt as DateTime?,
      deletedReason: deletedReason == _unset
          ? this.deletedReason
          : deletedReason as String?,
      deletedBy:
          deletedBy == _unset ? this.deletedBy : deletedBy as String?,
    );
  }

  static const Object _unset = Object();
}
