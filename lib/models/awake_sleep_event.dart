class Event {
  final String userId;
  final String type;
  final String timestamp;

  Event(this.userId, this.type, this.timestamp);

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'type': type,
      'timestamp': timestamp,
    };
  }

  static Event fromJson(Map<String, dynamic> json) {
    return Event(
      json['userId'] as String,
      json['type'] as String,
      json['timestamp'] as String,
    );
  }
}
