/// AI 설교 모델
class Sermon {
  final String id;
  final String title;
  final String verse;
  final String content;
  final String userPrompt;
  final DateTime createdAt;
  // 새롭게 추가된 필드들 (선택적)
  final String? topic;
  final String? situation;
  final String? length;
  final String? tone;
  final String? keyword;
  final String? audioUrl;

  Sermon({
    required this.id,
    required this.title,
    required this.verse,
    required this.content,
    required this.userPrompt,
    required this.createdAt,
    this.topic,
    this.situation,
    this.length,
    this.tone,
    this.keyword,
    this.audioUrl,
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
      'topic': topic,
      'situation': situation,
      'length': length,
      'tone': tone,
      'keyword': keyword,
      'audioUrl': audioUrl,
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
      topic: json['topic'] as String?,
      situation: json['situation'] as String?,
      length: json['length'] as String?,
      tone: json['tone'] as String?,
      keyword: json['keyword'] as String?,
      audioUrl: json['audioUrl'] as String?,
    );
  }

  /// 날짜 포맷팅 (예: "1월 15일")
  String get formattedDate {
    return '${createdAt.month}월 ${createdAt.day}일';
  }
}
