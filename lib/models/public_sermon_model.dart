import 'package:cloud_firestore/cloud_firestore.dart';

class PublicSermonModel {
  final String id;
  final String churchName;
  final String region;
  final String pastor;
  final String title;
  final String bibleVerse;
  final DateTime sermonDate;
  final String summary;
  final String application;
  final Map<String, String> devotionals; // day1~day6 (빈 맵이면 미제공)
  final DateTime broadcastDate;
  final String source;
  final DateTime createdAt;
  final String? audioUrl; // 설교 듣기용 캐시 오디오 URL (없으면 null)

  const PublicSermonModel({
    required this.id,
    required this.churchName,
    required this.region,
    required this.pastor,
    required this.title,
    required this.bibleVerse,
    required this.sermonDate,
    required this.summary,
    required this.application,
    this.devotionals = const {},
    required this.broadcastDate,
    required this.source,
    required this.createdAt,
    this.audioUrl,
  });

  factory PublicSermonModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return PublicSermonModel(
      id:            doc.id,
      churchName:    d['churchName']    ?? '',
      region:        d['region']        ?? '',
      pastor:        d['pastor']        ?? '',
      title:         d['title']         ?? '',
      bibleVerse:    d['bibleVerse']    ?? '',
      sermonDate:    (d['sermonDate']    as Timestamp?)?.toDate() ?? DateTime.now(),
      summary:       d['summary']       ?? '',
      application:   d['application']   ?? '',
      devotionals:   d['devotionals'] != null
          ? Map<String, String>.from(d['devotionals'] as Map)
          : const {},
      broadcastDate: (d['broadcastDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      source:        d['source']        ?? '데일리 말씀노트 공개 설교',
      createdAt:     (d['createdAt']    as Timestamp?)?.toDate() ?? DateTime.now(),
      audioUrl:      d['audioUrl']      as String?,
    );
  }

  String get formattedBroadcastDate {
    const days = ['월', '화', '수', '목', '금', '토', '일'];
    return '${broadcastDate.month}월 ${broadcastDate.day}일 (${days[broadcastDate.weekday - 1]})';
  }

  String get summaryPreview {
    final dot = summary.indexOf('.');
    if (dot > 0 && dot < summary.length - 1) return summary.substring(0, dot + 1);
    return summary.length > 60 ? '${summary.substring(0, 60)}…' : summary;
  }

  bool get isToday {
    final now = DateTime.now();
    return broadcastDate.year  == now.year  &&
           broadcastDate.month == now.month &&
           broadcastDate.day   == now.day;
  }
}
