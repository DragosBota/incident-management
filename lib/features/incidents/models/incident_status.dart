class IncidentStatus {
  static const String registered = 'REGISTERED';
  static const String inReview = 'IN_REVIEW';
  static const String waitingDepartment = 'WAITING_DEPARTMENT';
  static const String actionRequired = 'ACTION_REQUIRED';
  static const String closed = 'CLOSED';

  static const List<String> values = [
    registered,
    inReview,
    waitingDepartment,
    actionRequired,
    closed,
  ];
}