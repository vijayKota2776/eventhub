class EventReview {
  final String id;
  final String eventId;
  final String userId;
  final String userName;
  final int rating;
  final String? comment;
  final DateTime createdAt;

  const EventReview({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.userName,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory EventReview.fromJson(Map<String, dynamic> json) {
    return EventReview(
      id: json['id'] as String,
      eventId: json['event_id'] as String,
      userId: json['user_id'] as String,
      userName: (json['user_name'] ?? json['users']?['name'] ?? 'Attendee') as String,
      rating: (json['rating'] as num).toInt(),
      comment: json['comment'] as String?,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event_id': eventId,
      'user_id': userId,
      'user_name': userName,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
