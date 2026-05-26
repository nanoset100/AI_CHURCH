import 'package:flutter/foundation.dart';
import '../models/prayer_note_model.dart';
import '../services/prayer_note_service.dart';

class PrayerProvider extends ChangeNotifier {
  List<PrayerNoteModel> _notes     = [];
  bool                  _isLoading = false;

  List<PrayerNoteModel> get notes     => _notes;
  bool                  get isLoading => _isLoading;

  Future<void> loadNotes() async {
    _isLoading = true;
    notifyListeners();
    _notes = await PrayerNoteService.loadAll();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addNote({
    required String content,
    String? sermonTitle,
    String? bibleVerse,
  }) async {
    final note = PrayerNoteModel(
      id:          DateTime.now().millisecondsSinceEpoch.toString(),
      content:     content,
      sermonTitle: sermonTitle,
      bibleVerse:  bibleVerse,
      createdAt:   DateTime.now(),
    );
    await PrayerNoteService.save(note);
    _notes.insert(0, note);
    notifyListeners();
  }

  Future<void> deleteNote(String id) async {
    await PrayerNoteService.delete(id);
    _notes.removeWhere((n) => n.id == id);
    notifyListeners();
  }
}
