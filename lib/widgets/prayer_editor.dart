import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/public_sermon_model.dart';
import '../providers/prayer_provider.dart';

Future<void> writePrayer(
    BuildContext context, PublicSermonModel? sermon) async {
  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _PrayerEditor(sermon: sermon),
  );
  if (saved == true && context.mounted) {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('나의 기도제목에 저장했어요.')));
  }
}

class _PrayerEditor extends StatefulWidget {
  final PublicSermonModel? sermon;
  const _PrayerEditor({this.sermon});
  @override
  State<_PrayerEditor> createState() => _PrayerEditorState();
}

class _PrayerEditorState extends State<_PrayerEditor> {
  final _content = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _content.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final content = _content.text.trim();
    if (content.isEmpty || _saving) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await context.read<PrayerProvider>().addNote(
          content: content,
          sermonTitle: widget.sermon?.title,
          bibleVerse: widget.sermon?.bibleVerse);
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = '저장하지 못했어요. 다시 시도해 주세요.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('기도 쓰기', style: Theme.of(context).textTheme.titleLarge),
                  if (widget.sermon != null)
                    Text([widget.sermon!.title, widget.sermon!.bibleVerse]
                        .where((s) => s.isNotEmpty)
                        .join(' · ')),
                  const SizedBox(height: 12),
                  TextField(
                      controller: _content,
                      autofocus: true,
                      minLines: 3,
                      maxLines: 8,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                          hintText: '하나님께 하고 싶은 말을 적어주세요.',
                          errorText: _error,
                          border: const OutlineInputBorder())),
                  const SizedBox(height: 12),
                  FilledButton(
                      onPressed: _saving || _content.text.trim().isEmpty
                          ? null
                          : _save,
                      child: Text(_saving ? '저장 중' : '저장')),
                ]),
          )),
    );
  }
}
