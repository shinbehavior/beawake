class Event {
  final String type; // 'awake' or 'sleep'
  final DateTime timestamp;

  Event(this.type, this.timestamp);

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  static Event fromJson(Map<String, dynamic> json) {
    return Event(
      json['type'],
      DateTime.parse(json['timestamp']),
    );
  }
}
