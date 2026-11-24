import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../services/prayer_note_service.dart';
import '../../widgets/prayer_editor.dart';
import 'package:provider/provider.dart';
import '../../providers/prayer_provider.dart';
import '../../providers/sermon_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/prayer_note_card.dart';

class PrayerScreen extends StatefulWidget {
  const PrayerScreen({super.key});

  @override
  State<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends State<PrayerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PrayerProvider>().loadNotes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PrayerProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('나의 기도제목'), actions: [
        PopupMenuButton<bool>(
            tooltip: '기도제목 백업과 복원',
            onSelected: _transfer,
            itemBuilder: (_) => const [
                  PopupMenuItem(value: true, child: Text('기도제목 백업')),
                  PopupMenuItem(value: false, child: Text('기도제목 복원')),
                ]),
      ]),
      body: Column(
        children: [
          // 안내 문구
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: AppTheme.primary.withValues(alpha: 0.05),
            child: const Text(
              '조용히 혼자 하나님께 드리는 기도\n로그인 없이 이 기기에 저장됩니다.',
              style:
                  TextStyle(fontSize: 13, color: AppTheme.textMid, height: 1.6),
              textAlign: TextAlign.center,
            ),
          ),

          // 기도 목록
          Expanded(
            child: provider.notes.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8),
                    itemCount: provider.notes.length,
                    itemBuilder: (_, i) => PrayerNoteCard(
                      note: provider.notes[i],
                      onDelete: () => context
                          .read<PrayerProvider>()
                          .deleteNote(provider.notes[i].id),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            writePrayer(context, context.read<SermonProvider>().todaySermon),
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.edit_outlined, color: Colors.white),
        label: const Text('기도 쓰기', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.favorite_border, size: 48, color: AppTheme.textLight),
          SizedBox(height: 16),
          Text('아직 작성한 기도제목이 없어요',
              style: TextStyle(color: AppTheme.textMid, fontSize: 15)),
          SizedBox(height: 8),
          Text('오늘 하나님께 하고 싶은 말을 자유롭게 적어보세요',
              style: TextStyle(color: AppTheme.textLight, fontSize: 13)),
        ],
      ),
    );
  }

  Future<void> _transfer(bool exporting) async {
    final provider = context.read<PrayerProvider>();
    String message;
    try {
      if (exporting) {
        final bytes = utf8.encode(await provider.backup());
        final path = await FilePicker.platform.saveFile(
            dialogTitle: '기도제목 백업 저장', fileName: '나의 기도제목.json', bytes: bytes);
        if (path == null) return;
        message = '기도제목 백업 파일을 저장했어요.';
      } else {
        final picked = await FilePicker.platform.pickFiles(
            type: FileType.custom, allowedExtensions: ['json'], withData: true);
        if (picked == null) return;
        final bytes = picked.files.single.bytes;
        if (bytes == null) throw const FormatException();
        final notes = PrayerNoteService.readBackup(utf8.decode(bytes));
        if (!mounted) return;
        final confirmed = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
                    title: const Text('기도제목 복원'),
                    content: Text(
                        '백업에 기도제목이 ${notes.length}개 있어요. 현재 목록에 새 기록만 추가할까요?'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('취소')),
                      FilledButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('복원')),
                    ]));
        if (confirmed != true) return;
        final added = await provider.restore(notes);
        message = added == 0 ? '새로 추가할 기도제목이 없어요.' : '기도제목 $added개를 복원했어요.';
      }
    } on FormatException {
      message = 'AI 가나안교회에서 저장한 기도제목 백업 파일을 선택해 주세요.';
    } catch (_) {
      message = '파일을 처리하지 못했어요. 다시 시도해 주세요.';
    }
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }
}
