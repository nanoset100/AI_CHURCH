import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:ai_canaan_church/theme/app_theme.dart';
import 'package:ai_canaan_church/providers/sermon_provider.dart';
import 'package:ai_canaan_church/services/ai_service.dart';
import 'package:ai_canaan_church/screens/ai_sermon_loading_screen.dart';
import 'package:ai_canaan_church/screens/ai_sermon_result_screen.dart';

/// AI 설교 생성 다이얼로그
class AiSermonDialog extends StatefulWidget {
  const AiSermonDialog({super.key});

  @override
  State<AiSermonDialog> createState() => _AiSermonDialogState();
}

class _AiSermonDialogState extends State<AiSermonDialog> {
  final _promptController = TextEditingController();

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _handleGenerate() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '고민이나 주제를 입력해주세요.',
            style: GoogleFonts.notoSansKr(),
          ),
        ),
      );
      return;
    }

    // 다이얼로그 닫기
    Navigator.of(context).pop();

    // 로딩 화면으로 이동
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const AiSermonLoadingScreen(),
      ),
    );

    // 백그라운드에서 설교 생성
    final sermonProvider = Provider.of<SermonProvider>(context, listen: false);
    final sermon = await sermonProvider.generateSermon(prompt);

    if (!mounted) return;

    // 로딩 화면 닫기
    Navigator.of(context).pop();

    if (sermon != null) {
      // 결과 화면으로 이동
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AiSermonResultScreen(sermon: sermon),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            sermonProvider.errorMessage ?? '설교 생성에 실패했습니다.',
            style: GoogleFonts.notoSansKr(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _setSuggestion(String text) {
    _promptController.text = text;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final notoSansKr = GoogleFonts.notoSansKr();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 헤더
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '나만의 AI 설교 만들기',
                  style: notoSansKr.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textColor,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 입력 안내
            Text(
              '오늘 어떤 고민이 있으신가요?',
              style: notoSansKr.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '당신의 상황과 고민을 자유롭게 적어주세요. AI가 맞춤형 설교를 만들어드립니다.',
              style: notoSansKr.copyWith(
                fontSize: 14,
                color: AppTheme.textColor.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),

            // 고민 입력 필드
            TextField(
              controller: _promptController,
              maxLines: 5,
              style: notoSansKr,
              decoration: InputDecoration(
                hintText: '예: 직장에서 동료와의 갈등으로 마음이 힘듭니다. 용서해야 할지, 어떻게 대해야 할지 모르겠어요...',
                hintStyle: notoSansKr.copyWith(
                  color: AppTheme.textColor.withValues(alpha: 0.5),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 제안 키워드
            Text(
              '이런 주제는 어떠세요?',
              style: notoSansKr.copyWith(
                fontSize: 12,
                color: AppTheme.textColor.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AiService.getSuggestedKeywords().map((keyword) {
                return ActionChip(
                  label: Text(
                    keyword,
                    style: notoSansKr.copyWith(fontSize: 12),
                  ),
                  onPressed: () => _setSuggestion(keyword),
                  backgroundColor: AppTheme.secondaryColor,
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // 생성하기 버튼
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _handleGenerate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '설교 만들기',
                      style: notoSansKr.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('✨', style: TextStyle(fontSize: 20)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
