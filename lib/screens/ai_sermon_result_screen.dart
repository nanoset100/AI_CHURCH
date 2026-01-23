import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:ai_canaan_church/theme/app_theme.dart';
import 'package:ai_canaan_church/models/sermon.dart';
import 'package:ai_canaan_church/providers/sermon_provider.dart';
import 'package:ai_canaan_church/screens/home_screen.dart';

/// AI 설교 결과 화면
class AiSermonResultScreen extends StatelessWidget {
  final Sermon sermon;

  const AiSermonResultScreen({
    super.key,
    required this.sermon,
  });

  Future<void> _handleSave(BuildContext context) async {
    final sermonProvider = Provider.of<SermonProvider>(context, listen: false);
    final success = await sermonProvider.saveSermon(sermon);

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '설교가 보관되었습니다!',
            style: GoogleFonts.notoSansKr(),
          ),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            sermonProvider.errorMessage ?? '설교 저장에 실패했습니다.',
            style: GoogleFonts.notoSansKr(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final notoSansKr = GoogleFonts.notoSansKr();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          color: AppTheme.textColor,
          onPressed: () {
            Provider.of<SermonProvider>(context, listen: false).clearCurrentSermon();
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          },
        ),
        title: Text(
          'AI 맞춤 설교',
          style: notoSansKr.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textColor,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 배지
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'AI 맞춤 설교',
                style: notoSansKr.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),

            // 제목
            Text(
              sermon.title,
              style: notoSansKr.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor,
              ),
            ),
            const SizedBox(height: 12),

            // 성경 구절
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.secondaryColor.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.primaryColor.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                sermon.verse,
                style: notoSansKr.copyWith(
                  fontSize: 14,
                  color: AppTheme.textColor,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 설교 본문
            Text(
              sermon.content,
              style: notoSansKr.copyWith(
                fontSize: 16,
                height: 1.8,
                color: AppTheme.textColor,
              ),
            ),
            const SizedBox(height: 32),

            // 사용자 고민 (작은 글씨로)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '"${sermon.userPrompt}"',
                      style: notoSansKr.copyWith(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 버튼 영역
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Provider.of<SermonProvider>(context, listen: false).clearCurrentSermon();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      side: BorderSide(color: AppTheme.primaryColor),
                    ),
                    child: Text(
                      '다시 만들기',
                      style: notoSansKr.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _handleSave(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '보관하기',
                          style: notoSansKr.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text('💾', style: TextStyle(fontSize: 18)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
