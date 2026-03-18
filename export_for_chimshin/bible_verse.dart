class BibleVerse {
  final int id;
  final String bookName;
  final int chapter;
  final int verseNumber;
  final String verseText;
  final String? subtitleTitle;
  final String? audioUrl; // 새로 추가된 음성 파일 URL

  BibleVerse({
    required this.id,
    required this.bookName,
    required this.chapter,
    required this.verseNumber,
    required this.verseText,
    this.subtitleTitle,
    this.audioUrl,
  });

  factory BibleVerse.fromJson(Map<String, dynamic> json) {
    return BibleVerse(
      id: json['id'] as int,
      bookName: json['book_name'] as String,
      chapter: json['chapter'] as int,
      verseNumber: json['verse_number'] as int,
      verseText: json['verse_text'] as String,
      subtitleTitle: json['subtitle_title'] as String?,
      audioUrl: json['audio_url'] as String?, // 매핑 추가
    );
  }
}
