import 'package:flutter/material.dart';
import '../models/prayer_note_model.dart';
import '../theme/app_theme.dart';

class PrayerNoteCard extends StatelessWidget {
  final PrayerNoteModel note;
  final VoidCallback onDelete;
  const PrayerNoteCard({super.key, required this.note, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(note.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red.shade400,
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      // 실수 삭제 방지 — 확인 다이얼로그
      confirmDismiss: (_) async {
        return await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('기도제목 삭제'),
                content: const Text('이 기도제목을 삭제할까요?\n한번 삭제하면 복구할 수 없습니다.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('취소'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('삭제'),
                  ),
                ],
              ),
            ) ??
            false;
      },
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text(note.formattedDate,
                  style:
                      const TextStyle(fontSize: 12, color: AppTheme.textLight)),
              if (note.sermonTitle != null) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '📖 ${note.sermonTitle}',
                    style:
                        const TextStyle(fontSize: 12, color: AppTheme.primary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ]),
            const SizedBox(height: 8),
            Text(note.content,
                style: const TextStyle(
                    fontSize: 15, color: AppTheme.textDark, height: 1.6)),
          ],
        ),
      ),
    );
  }
}
