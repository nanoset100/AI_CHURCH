class PrayerRequest {
  final String id;
  final String userId;
  final String title;
  final String category;
  final bool isAnswered;
  final DateTime createdAt;

  PrayerRequest({
    required this.id,
    required this.userId,
    required this.title,
    required this.category,
    required this.isAnswered,
    required this.createdAt,
  });

  factory PrayerRequest.fromJson(Map<String, dynamic> json) {
    return PrayerRequest(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String? ?? json['text'] as String? ?? '', // 호환성을 위해 title과 text 모두 확인
      category: json['category'] as String,
      isAnswered: json['is_answered'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'category': category,
      'is_answered': isAnswered,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
