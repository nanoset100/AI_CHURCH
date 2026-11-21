import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../providers/sermon_provider.dart';
import '../../widgets/today_sermon_card.dart';
import '../../widgets/weekly_strip.dart';
import '../../widgets/welcome_popup.dart';
import '../search/sermon_detail_screen.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SermonProvider>().loadToday();
      WelcomePopup.showIfNeeded(context); // 최초 실행 시 1회 환영 팝업
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SermonProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 가나안교회'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: _showAbout,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<SermonProvider>().loadToday(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              if (provider.isTodayLoading)
                _buildSkeleton()
              else if (provider.todaySermon != null)
                TodaySermonCard(sermon: provider.todaySermon!)
              else
                _buildEmpty(),
              if (provider.weekSermons.isNotEmpty)
                WeeklyStrip(
                  sermons: provider.weekSermons,
                  onTap: (s) => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => SermonDetailScreen(sermon: s)),
                  ),
                ),
              _buildFooterNote(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final formatted = DateFormat('yyyy년 M월 d일 (E)', 'ko').format(DateTime.now());
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(formatted,
              style: const TextStyle(fontSize: 13, color: AppTheme.textMid)),
          const SizedBox(height: 4),
          const Text('오늘도 말씀 하나, 하나님과 함께해요',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark)),
        ],
      ),
    );
  }

  Widget _buildSkeleton() {
    return Container(
      margin: const EdgeInsets.all(16),
      height: 280,
      decoration: BoxDecoration(
        color: AppTheme.divider,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  Widget _buildEmpty() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        children: [
          const Icon(Icons.hourglass_empty,
              color: AppTheme.textLight, size: 40),
          const SizedBox(height: 12),
          const Text('오늘 말씀이 아직 준비 중입니다',
              style: TextStyle(color: AppTheme.textMid, fontSize: 15)),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => context.read<SermonProvider>().loadToday(),
            child: const Text('새로고침'),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterNote() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.radio, size: 16, color: AppTheme.primary),
            SizedBox(width: 6),
            Text('데일리 말씀노트 공개 설교',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary)),
          ]),
          SizedBox(height: 8),
          Text(
            '데일리 말씀노트에 공개된 설교를 AI가 요약해 매일 전달합니다.\n'
            '강요도 없고, 권위도 없어요. 그냥 오늘 말씀 한 편.',
            style: TextStyle(
                fontSize: 13, color: AppTheme.textMid, height: 1.6),
          ),
        ],
      ),
    );
  }

  void _showAbout() {
    showModalBottomSheet(
      context: context,
      builder: (_) => const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('AI 가나안교회',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Text(
              '당신이 교회를 떠난 이유를 묻지 않겠습니다.\n'
              '그냥 오늘 이 말씀 하나 읽어주세요.\n\n'
              '데일리 말씀노트에 공개된\n'
              '설교를 AI가 요약하여 매일 제공합니다.',
              style: TextStyle(color: AppTheme.textMid, height: 1.7),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
