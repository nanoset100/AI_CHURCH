import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:ai_canaan_church/theme/app_theme.dart';
import 'package:ai_canaan_church/widgets/greeting_section.dart';
import 'package:ai_canaan_church/widgets/ai_sermon_card.dart';
import 'package:ai_canaan_church/widgets/daily_worship_card.dart';
import 'package:ai_canaan_church/widgets/daily_bible_card.dart';
import 'package:ai_canaan_church/widgets/prayer_requests_card.dart';
import 'package:ai_canaan_church/widgets/saved_sermons_card.dart';
import 'package:ai_canaan_church/widgets/weekly_activity_card.dart';
import 'package:ai_canaan_church/providers/sermon_provider.dart';
import 'package:ai_canaan_church/providers/bible_provider.dart';
import 'package:ai_canaan_church/providers/prayer_provider.dart';
import 'package:ai_canaan_church/providers/activity_provider.dart';
import 'package:ai_canaan_church/screens/profile_screen.dart';
import 'package:ai_canaan_church/screens/notification_screen.dart';

/// 홈 화면 - CustomScrollView와 Sliver 구조로 부드러운 스크롤 구현
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // 각종 초기 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SermonProvider>(context, listen: false).loadSavedSermons();
      Provider.of<BibleProvider>(context, listen: false).fetchDailyPreview();
      Provider.of<PrayerProvider>(context, listen: false).fetchPrayerRequests();
      Provider.of<ActivityProvider>(context, listen: false).fetchActivityStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notoSansKr = GoogleFonts.notoSansKr();
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          // 상단 헤더 (고정)
          SliverAppBar(
            backgroundColor: AppTheme.primaryColor,
            elevation: 0,
            pinned: true,
            leading: Center(
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.person_outline),
                  color: Colors.white,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    );
                  },
                ),
              ),
            ),
            title: Text(
              'AI 가나안교회',
              style: notoSansKr.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            centerTitle: true,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.notifications_outlined),
                    color: Colors.white,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const NotificationScreen()),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          
          // 인사말 섹션
          SliverToBoxAdapter(
            child: const GreetingSection(),
          ),
          
          // AI 설교 만들기 카드 (핵심 기능 - 강조)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: const AiSermonCard(),
            ),
          ),
          
          // 오늘의 예배 카드
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: const DailyWorshipCard(),
            ),
          ),
          
          // 오늘의 성경 카드
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: const DailyBibleCard(),
            ),
          ),
          
          // 나의 기도제목 카드
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: const PrayerRequestsCard(),
            ),
          ),
          
          // 보관된 설교 카드
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: const SavedSermonsCard(),
            ),
          ),
          
          // 이번 주 활동 카드
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: const WeeklyActivityCard(),
            ),
          ),
          
          // 하단 여백 (Bottom Navigation Bar 공간 확보)
          // 하단 여백 추가 (네비게이션바 오버플로우 방지)
          const SliverPadding(
            padding: EdgeInsets.only(bottom: 60),
          ),
        ],
      ),
    );
  }
}
