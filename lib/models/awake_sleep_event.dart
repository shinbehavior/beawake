class Event {
  final String type; // 'awake' or 'sleep'
  final String timestamp;

  Event(this.type, this.timestamp);

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'timestamp': timestamp,
    };
  }

  static Event fromJson(Map<String, dynamic> json) {
    return Event(
      json['type'],
      json['timestamp'] as String,
    );
  }
}
