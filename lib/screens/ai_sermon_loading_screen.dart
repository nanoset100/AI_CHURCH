import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ai_canaan_church/theme/app_theme.dart';

/// AI 설교 생성 중 로딩 화면
class AiSermonLoadingScreen extends StatefulWidget {
  const AiSermonLoadingScreen({super.key});

  @override
  State<AiSermonLoadingScreen> createState() => _AiSermonLoadingScreenState();
}

class _AiSermonLoadingScreenState extends State<AiSermonLoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  static const _verses = [
    '"여호와를 앙망하는 자는 새 힘을 얻으리니"\n- 이사야 40:31',
    '"내가 너와 함께 하여 어디로 가든지 너를 지키리라"\n- 창세기 28:15',
    '"너희 염려를 다 주께 맡기라 이는 그가 너희를 돌보심이라"\n- 베드로전서 5:7',
    '"주는 나의 목자시니 내게 부족함이 없으리로다"\n- 시편 23:1',
    '"믿음은 바라는 것들의 실상이요 보이지 않는 것들의 증거니"\n- 히브리서 11:1',
    '"하나님이 세상을 이처럼 사랑하사 독생자를 주셨으니"\n- 요한복음 3:16',
    '"범사에 감사하라 이것이 그리스도 예수 안에서 너희를 향하신 하나님의 뜻이니라"\n- 데살로니가전서 5:18',
    '"두려워하지 말라 내가 너와 함께 함이라"\n- 이사야 41:10',
    '"나는 포도나무요 너희는 가지라"\n- 요한복음 15:5',
    '"주의 말씀은 내 발에 등이요 내 길에 빛이니이다"\n- 시편 119:105',
  ];

  late final String _verse;

  @override
  void initState() {
    super.initState();
    _verse = _verses[Random().nextInt(_verses.length)];
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notoSansKr = GoogleFonts.notoSansKr();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 애니메이션 로딩 아이콘
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _animation.value,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        '🙏',
                        style: TextStyle(fontSize: 64),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),

            // 로딩 텍스트
            Text(
              '당신을 위한 설교를 준비하고 있습니다...',
              style: notoSansKr.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // 성경 구절
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.symmetric(horizontal: 32),
              decoration: BoxDecoration(
                color: AppTheme.secondaryColor.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _verse,
                style: notoSansKr.copyWith(
                  fontSize: 14,
                  color: AppTheme.textColor.withValues(alpha: 0.8),
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),

            // 로딩 인디케이터
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
          ],
        ),
      ),
    );
  }
}
