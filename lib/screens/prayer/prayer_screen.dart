import 'package:flutter/material.dart';
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
      appBar: AppBar(title: const Text('기도 노트')),
      body: Column(
        children: [
          // 안내 문구
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: AppTheme.primary.withValues(alpha: 0.05),
            child: const Text(
              '조용히 혼자 하나님께 드리는 기도\n로그인 없이 이 기기에 저장됩니다.',
              style: TextStyle(
                  fontSize: 13, color: AppTheme.textMid, height: 1.6),
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
                      onDelete: () =>
                          context.read<PrayerProvider>().deleteNote(
                              provider.notes[i].id),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context),
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
          Text('아직 기도 노트가 없어요',
              style: TextStyle(color: AppTheme.textMid, fontSize: 15)),
          SizedBox(height: 8),
          Text('오늘 하나님께 하고 싶은 말을 자유롭게 적어보세요',
              style: TextStyle(color: AppTheme.textLight, fontSize: 13)),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final ctrl = TextEditingController();
    final sermon = context.read<SermonProvider>().todaySermon;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('오늘의 기도',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            if (sermon != null) ...[
              const SizedBox(height: 4),
              Text('오늘 말씀: ${sermon.title}',
                  style: const TextStyle(
                      fontSize: 12, color: AppTheme.textLight)),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              minLines: 4,
              maxLines: 10,
              autofocus: true,
              decoration: InputDecoration(
                hintText: '하나님께 하고 싶은 말을 자유롭게 적어주세요...',
                hintStyle: const TextStyle(color: AppTheme.textLight),
                filled: true,
                fillColor: AppTheme.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.divider),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  if (ctrl.text.trim().isNotEmpty) {
                    context.read<PrayerProvider>().addNote(
                          content: ctrl.text.trim(),
                          sermonTitle: sermon?.title,
                          bibleVerse: sermon?.bibleVerse,
                        );
                    Navigator.pop(ctx);
                  }
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('저장', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
