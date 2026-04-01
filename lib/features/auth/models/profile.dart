class Profile {
  final String id;
  final String firstName;
  final String lastName;
  final String departmentId;

  Profile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.departmentId,
  });

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'] as String,
      firstName: map['first_name'] as String,
      lastName: map['last_name'] as String,
      departmentId: map['department_id'] as String,
    );
  }
}