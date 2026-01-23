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

  @override
  void initState() {
    super.initState();
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
                '"여호와를 앙망하는 자는 새 힘을 얻으리니"\n- 이사야 40:31',
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
