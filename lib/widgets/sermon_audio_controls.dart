import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class SermonAudioControls extends StatelessWidget {
  final Duration position;
  final Duration duration;
  final bool isPlaying;
  final bool isLoading;
  final VoidCallback onToggle;
  final VoidCallback? onStop;
  final ValueChanged<Duration> onSeek;
  final String? error;
  final bool compact;

  const SermonAudioControls({
    super.key,
    required this.position,
    required this.duration,
    required this.isPlaying,
    required this.isLoading,
    required this.onToggle,
    required this.onStop,
    required this.onSeek,
    this.error,
    this.compact = false,
  });

  String _formatTime(Duration time) {
    final minutes = time.inMinutes.toString().padLeft(2, '0');
    final seconds = (time.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final hasDuration = duration.inMilliseconds > 0;
    final progress = hasDuration
        ? (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;
    final timeStyle = Theme.of(context).textTheme.bodyMedium;
    const title = Row(
      children: [
        Icon(Icons.mic_none, size: 16, color: AppTheme.primary),
        SizedBox(width: 6),
        Flexible(
          child: Text('설교 듣기',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppTheme.primary,
              )),
        ),
      ],
    );
    final buttons = [
      IconButton.filled(
        tooltip: isPlaying ? '일시정지' : '재생',
        onPressed: isLoading ? null : onToggle,
        style: IconButton.styleFrom(
          fixedSize: Size.square(compact ? 48 : 52),
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
        ),
        icon: isLoading
            ? const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(isPlaying ? Icons.pause : Icons.play_arrow, size: 28),
      ),
      SizedBox(width: compact ? 8 : 16),
      IconButton.filledTonal(
        tooltip: '정지',
        onPressed: onStop,
        icon: const Icon(Icons.stop),
      ),
    ];
    return Container(
      padding: compact
          ? const EdgeInsets.fromLTRB(16, 6, 16, 8)
          : const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (compact)
            Row(children: [const Expanded(child: title), ...buttons])
          else
            title,
          SliderTheme(
            data: SliderTheme.of(context).copyWith(trackHeight: 4),
            child: Slider(
              value: progress,
              activeColor: AppTheme.primary,
              inactiveColor: AppTheme.divider,
              onChanged:
                  hasDuration ? (value) => onSeek(duration * value) : null,
              semanticFormatterCallback: (value) {
                final time = duration * value;
                return '${time.inMinutes}분 ${time.inSeconds % 60}초';
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Semantics(
                label: '현재 재생 시간',
                child: Text(_formatTime(position), style: timeStyle),
              ),
              Semantics(
                label: '전체 재생 시간',
                child: Text(hasDuration ? _formatTime(duration) : '--:--',
                    style: timeStyle),
              ),
            ],
          ),
          if (!compact) ...[
            const SizedBox(height: 4),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: buttons),
          ],
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(error!, style: timeStyle),
            ),
        ],
      ),
    );
  }
}
