import 'package:flutter/material.dart';
import '../models/public_sermon_model.dart';
import '../theme/app_theme.dart';

class WeeklyStrip extends StatelessWidget {
  final List<PublicSermonModel> sermons;
  final void Function(PublicSermonModel) onTap;
  const WeeklyStrip({super.key, required this.sermons, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Text('이번 주 말씀',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark)),
        ),
        SizedBox(
          height: 88,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: sermons.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) {
              final s = sermons[i];
              final isToday = s.isToday;
              return GestureDetector(
                onTap: () => onTap(s),
                child: Container(
                  width: 80,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isToday ? AppTheme.primary : AppTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: isToday ? AppTheme.primary : AppTheme.divider),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${s.broadcastDate.month}/${s.broadcastDate.day}',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isToday ? Colors.white : AppTheme.textDark),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        // 성경 본문에서 책 이름만 표시 (콜론 앞부분)
                        s.bibleVerse.contains(':')
                            ? s.bibleVerse.split(':')[0]
                            : s.bibleVerse,
                        style: TextStyle(
                            fontSize: 11,
                            color: isToday ? Colors.white : AppTheme.textMid),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
