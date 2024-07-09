class Friend {
  final String id;
  final String name;
  final String email;
  final String avatarUrl;
  final String currentState;
  final DateTime currentStateTime;
  final String previousState;
  final DateTime previousStateTime;

  Friend({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.currentState,
    required this.currentStateTime,
    required this.previousState,
    required this.previousStateTime,
  });
}