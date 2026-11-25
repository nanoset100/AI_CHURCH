import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../models/public_sermon_model.dart';
import '../theme/app_theme.dart';
import 'sermon_audio_player.dart';
import '../screens/search/sermon_detail_screen.dart';

class TodaySermonCard extends StatelessWidget {
  final PublicSermonModel sermon;
  final bool compact;
  final bool shortViewport;
  const TodaySermonCard({
    super.key,
    required this.sermon,
    this.compact = false,
    this.shortViewport = false,
  });

  @override
  Widget build(BuildContext context) {
    final readBeforeSummary = compact && shortViewport;
    final date =
        readBeforeSummary && sermon.broadcastDate.year == DateTime.now().year
            ? '${sermon.broadcastDate.month}월 ${sermon.broadcastDate.day}일'
            : '${sermon.broadcastDate.year}년 ${sermon.formattedBroadcastDate}';
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: 16, vertical: readBeforeSummary ? 4 : 8),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더 뱃지
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: 16, vertical: readBeforeSummary ? 6 : 10),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.08),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Icon(Icons.radio, size: 14, color: AppTheme.primary),
                const Text('데일리 말씀노트 공개 설교',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary)),
                Text('게시일 $date',
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textLight)),
              ],
            ),
          ),

          Padding(
            padding: readBeforeSummary
                ? const EdgeInsets.fromLTRB(16, 10, 16, 12)
                : const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 제목
                Text(sermon.title,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        height: 1.3)),
                const SizedBox(height: 6),

                // 성경 본문 | 목사
                Text(
                    [sermon.bibleVerse, sermon.pastor]
                        .where((s) => s.isNotEmpty)
                        .join('  |  '),
                    style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.accent,
                        fontWeight: FontWeight.w600)),

                // 교회 · 지역
                Text(
                    [sermon.churchName, sermon.region]
                        .where((s) => s.isNotEmpty)
                        .join(' · '),
                    style: const TextStyle(
                        fontSize: 13, color: AppTheme.textLight)),
                SizedBox(height: readBeforeSummary ? 8 : 16),

                // 설교 듣기 (캐시 오디오 있을 때만)
                if (sermon.audioUrl != null && sermon.audioUrl!.isNotEmpty) ...[
                  SermonAudioPlayer(
                    audioUrl: sermon.audioUrl!,
                    compact: readBeforeSummary,
                  ),
                  SizedBox(height: readBeforeSummary ? 8 : 16),
                ],

                if (readBeforeSummary) ...[
                  _buildReadButton(context),
                  const SizedBox(height: 12),
                ],

                // 설교 요약
                const _SectionLabel(label: '설교 요약'),
                const SizedBox(height: 8),
                Text(sermon.summary,
                    maxLines: readBeforeSummary ? 2 : (compact ? 3 : null),
                    overflow: compact ? TextOverflow.ellipsis : null,
                    style: const TextStyle(
                        fontSize: 15, color: AppTheme.textDark, height: 1.75)),

                // 오늘의 적용 (있을 때만)
                if (!compact && sermon.application.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const _SectionLabel(label: '오늘의 적용', accent: true),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(sermon.application,
                        maxLines: compact ? 3 : null,
                        overflow: compact ? TextOverflow.ellipsis : null,
                        style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textDark,
                            height: 1.7)),
                  ),
                ],
                // 6일 묵상 (있을 때만)
                if (!compact && sermon.devotionals.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const _SectionLabel(label: '6일 묵상'),
                  const SizedBox(height: 10),
                  ...['day1', 'day2', 'day3', 'day4', 'day5', 'day6']
                      .where((k) => sermon.devotionals[k]?.isNotEmpty == true)
                      .map((k) => _DevoCard(
                            dayKey: k,
                            content: sermon.devotionals[k]!,
                          )),
                ],
                if (!readBeforeSummary) const SizedBox(height: 16),
                if (compact && !readBeforeSummary) _buildReadButton(context),
                const SizedBox(height: 8),

                // 공유 버튼
                if (!compact)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _share(sermon),
                      icon: const Icon(Icons.share_outlined, size: 18),
                      label: const Text('이 말씀 나누기'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primary,
                        side: const BorderSide(color: AppTheme.primary),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SermonDetailScreen(sermon: sermon)),
        ),
        icon: const Icon(Icons.menu_book_outlined),
        label: const Text('말씀과 묵상 전체 읽기'),
      ),
    );
  }

  void _share(PublicSermonModel s) {
    Share.share(
      '📖 ${s.title}\n${s.bibleVerse} · ${s.pastor}\n\n'
      '${s.summary}\n\n✏️ 오늘의 적용\n${s.application}\n\n'
      '— AI 가나안교회 · 데일리 말씀노트 공개 설교',
    );
  }
}

class _DevoCard extends StatelessWidget {
  final String dayKey;
  final String content;
  const _DevoCard({required this.dayKey, required this.content});

  static const _labels = {
    'day1': '월',
    'day2': '화',
    'day3': '수',
    'day4': '목',
    'day5': '금',
    'day6': '토',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              _labels[dayKey] ?? '',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              content,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textDark,
                height: 1.65,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final bool accent;
  const _SectionLabel({required this.label, this.accent = false});

  @override
  Widget build(BuildContext context) {
    final color = accent ? AppTheme.accent : AppTheme.primary;
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 8),
        Text(label,
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w700, color: color)),
      ],
    );
  }
}
