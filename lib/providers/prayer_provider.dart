import 'package:flutter/foundation.dart';
import '../models/prayer_note_model.dart';
import '../services/prayer_note_service.dart';

class PrayerProvider extends ChangeNotifier {
  List<PrayerNoteModel> _notes = [];
  List<PrayerNoteModel> get notes => List.unmodifiable(_notes);
  Future<void> _pending = Future.value();

  // Reads, edits and imports must observe the preceding completed write.
  Future<T> _queue<T>(Future<T> Function() operation) {
    final result = _pending.then((_) => operation());
    _pending = result.then<void>((_) {}, onError: (Object _, StackTrace __) {});
    return result;
  }

  Future<void> loadNotes() => _queue(() async {
        _notes = await PrayerNoteService.loadAll();
        notifyListeners();
      });

  Future<void> _commit(List<PrayerNoteModel> notes) async {
    notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    await PrayerNoteService.store(notes);
    _notes = notes;
    notifyListeners();
  }

  Future<void> addNote(
          {required String content, String? sermonTitle, String? bibleVerse}) =>
      _queue(() async {
        final notes = await PrayerNoteService.loadAll();
        final now = DateTime.now();
        var id = now.microsecondsSinceEpoch;
        while (notes.any((note) => note.id == id.toString())) {
          id++;
        }
        notes.add(PrayerNoteModel(
            id: id.toString(),
            content: content,
            sermonTitle: sermonTitle,
            bibleVerse: bibleVerse,
            createdAt: now));
        await _commit(notes);
      });

  Future<void> deleteNote(String id) => _queue(() async {
        final notes = await PrayerNoteService.loadAll();
        notes.removeWhere((note) => note.id == id);
        await _commit(notes);
      });

  Future<String> backup() => _queue(
      () async => PrayerNoteService.backup(await PrayerNoteService.loadAll()));

  Future<int> restore(List<PrayerNoteModel> imported) => _queue(() async {
        final notes = await PrayerNoteService.loadAll();
        final byId = {for (final note in notes) note.id: note};
        var added = 0;
        for (final note in imported) {
          var id = note.id;
          var suffix = 0;
          while (byId.containsKey(id)) {
            final existing = byId[id]!;
            if (existing.content == note.content &&
                existing.createdAt == note.createdAt &&
                existing.sermonTitle == note.sermonTitle &&
                existing.bibleVerse == note.bibleVerse) {
              break;
            }
            id = '${note.id}~${++suffix}';
          }
          if (byId.containsKey(id)) continue;
          byId[id] = PrayerNoteModel.fromJson({...note.toJson(), 'id': id});
          added++;
        }
        if (added > 0) await _commit(byId.values.toList());
        return added;
      });
}
