import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/prayer_note_model.dart';

class PrayerNoteService {
  static const _key = 'prayer_notes';

  static Future<List<PrayerNoteModel>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => PrayerNoteModel.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  static Future<void> save(PrayerNoteModel note) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await loadAll();
    list.insert(0, note);
    await prefs.setString(_key,
        jsonEncode(list.map((e) => e.toJson()).toList()));
  }

  static Future<void> delete(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await loadAll();
    list.removeWhere((e) => e.id == id);
    await prefs.setString(_key,
        jsonEncode(list.map((e) => e.toJson()).toList()));
  }
}
