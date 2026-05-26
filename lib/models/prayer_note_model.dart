class PrayerNoteModel {
  final String id;
  final String content;
  final String? sermonTitle;
  final String? bibleVerse;
  final DateTime createdAt;

  const PrayerNoteModel({
    required this.id,
    required this.content,
    this.sermonTitle,
    this.bibleVerse,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'content': content,
    'sermonTitle': sermonTitle,
    'bibleVerse': bibleVerse,
    'createdAt': createdAt.millisecondsSinceEpoch,
  };

  factory PrayerNoteModel.fromJson(Map<String, dynamic> json) {
    return PrayerNoteModel(
      id:          json['id'] as String,
      content:     json['content'] as String,
      sermonTitle: json['sermonTitle'] as String?,
      bibleVerse:  json['bibleVerse'] as String?,
      createdAt:   DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
    );
  }

  String get formattedDate {
    return '${createdAt.year}.'
        '${createdAt.month.toString().padLeft(2, '0')}.'
        '${createdAt.day.toString().padLeft(2, '0')}';
  }
}
