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
import 'package:ai_canaan_church/widgets/bottom_nav_bar.dart';
import 'package:ai_canaan_church/providers/sermon_provider.dart';

/// 홈 화면 - CustomScrollView와 Sliver 구조로 부드러운 스크롤 구현
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    // 저장된 설교 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SermonProvider>(context, listen: false).loadSavedSermons();
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
            backgroundColor: AppTheme.backgroundColor,
            elevation: 0,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.person_outline),
              color: AppTheme.textColor,
              onPressed: () {
                // 프로필 화면으로 이동 (추후 구현)
              },
            ),
            title: Text(
              'AI 가나안교회',
              style: notoSansKr.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor,
              ),
            ),
            centerTitle: true,
            actions: [
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    color: AppTheme.textColor,
                    onPressed: () {
                      // 알림 화면으로 이동 (추후 구현)
                    },
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
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
          const SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() {
            _currentNavIndex = index;
          });
          // 네비게이션 처리 (추후 구현)
        },
      ),
    );
  }
}
