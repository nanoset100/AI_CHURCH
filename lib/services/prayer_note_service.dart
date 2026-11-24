import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/prayer_note_model.dart';

class PrayerNoteService {
  static const _key = 'prayer_notes';

  static Future<List<PrayerNoteModel>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    return (jsonDecode(raw) as List)
        .map((item) => PrayerNoteModel.fromJson(item as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  static Future<void> store(List<PrayerNoteModel> notes) async {
    final prefs = await SharedPreferences.getInstance();
    if (!await prefs.setString(_key, jsonEncode(notes))) {
      throw StateError('기도제목을 저장하지 못했습니다.');
    }
  }

  static String backup(List<PrayerNoteModel> notes) => jsonEncode({
        'format': 'ai-canaan-church/prayers',
        'version': 1,
        'notes': notes,
      });

  static List<PrayerNoteModel> readBackup(String text) {
    try {
      final data = jsonDecode(text);
      if (data is! Map ||
          data['format'] != 'ai-canaan-church/prayers' ||
          data['version'] != 1 ||
          data['notes'] is! List) {
        throw const FormatException();
      }
      return (data['notes'] as List).map((item) {
        final note = PrayerNoteModel.fromJson(item as Map<String, dynamic>);
        if (note.id.isEmpty || note.content.trim().isEmpty) {
          throw const FormatException();
        }
        return note;
      }).toList();
    } catch (_) {
      throw const FormatException('AI 가나안교회 기도제목 백업 파일을 선택해 주세요.');
    }
  }
}
