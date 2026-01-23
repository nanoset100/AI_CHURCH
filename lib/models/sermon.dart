/// AI 설교 모델
class Sermon {
  final String id;
  final String title;
  final String verse;
  final String content;
  final String userPrompt;
  final DateTime createdAt;

  Sermon({
    required this.id,
    required this.title,
    required this.verse,
    required this.content,
    required this.userPrompt,
    required this.createdAt,
  });

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'verse': verse,
      'content': content,
      'userPrompt': userPrompt,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// JSON에서 생성
  factory Sermon.fromJson(Map<String, dynamic> json) {
    return Sermon(
      id: json['id'] as String,
      title: json['title'] as String,
      verse: json['verse'] as String,
      content: json['content'] as String,
      userPrompt: json['userPrompt'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// 날짜 포맷팅 (예: "1월 15일")
  String get formattedDate {
    return '${createdAt.month}월 ${createdAt.day}일';
  }
}
