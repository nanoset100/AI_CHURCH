import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:ai_canaan_church/theme/app_theme.dart';
import 'package:ai_canaan_church/providers/sermon_provider.dart';
import 'package:ai_canaan_church/screens/ai_sermon_loading_screen.dart';
import 'package:ai_canaan_church/screens/ai_sermon_result_screen.dart';

/// AI 설교 생성 다이얼로그
class AiSermonDialog extends StatefulWidget {
  const AiSermonDialog({super.key});

  @override
  State<AiSermonDialog> createState() => _AiSermonDialogState();
}

class _AiSermonDialogState extends State<AiSermonDialog> {
  // 상태 저장을 위한 변수들
  String _selectedTopic = '위로';
  String? _selectedSituation;
  String _selectedLength = '7분';
  String? _selectedTone = '따뜻하게';
  final _keywordController = TextEditingController();

  final List<String> _topics = ['위로', '불안', '감사', '기도', '관계', '용서', '결단', '인도'];
  final List<String> _situations = ['혼자 예배', '출근길', '잠들기 전', '병상', '우울할 때'];
  final List<String> _lengths = ['3분', '7분', '12분'];
  final List<String> _tones = ['따뜻하게', '차분하게', '도전적으로'];

  @override
  void dispose() {
    _keywordController.dispose();
    super.dispose();
  }

  Future<void> _handleGenerate() async {
    // Scaffold 및 Navigator 상태 미리 캡처 (await 이후 context 사용 오류 방지)
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final sermonProvider = Provider.of<SermonProvider>(context, listen: false);

    // 다이얼로그 닫기
    navigator.pop();

    // 로딩 화면으로 이동
    navigator.push(
      MaterialPageRoute(
        builder: (_) => const AiSermonLoadingScreen(),
      ),
    );

    // 백그라운드에서 설교 생성 (구조화된 데이터 전달)
    final sermon = await sermonProvider.generateSermon(
      topic: _selectedTopic,
      situation: _selectedSituation,
      length: _selectedLength,
      tone: _selectedTone,
      keyword: _keywordController.text.trim(),
    );

    // 로딩 화면 닫기
    navigator.pop();

    if (sermon != null) {
      // 결과 화면으로 이동
      navigator.push(
        MaterialPageRoute(
          builder: (_) => AiSermonResultScreen(sermon: sermon),
        ),
      );
    } else {
      scaffoldMessenger.showSnackBar(
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

  @override
  Widget build(BuildContext context) {
    final notoSansKr = GoogleFonts.notoSansKr();
    final screenSize = MediaQuery.of(context).size;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: BoxConstraints(
          maxWidth: 550,
          maxHeight: screenSize.height * 0.85, // 화면 높이의 85%로 제한
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 헤더 (고정)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'AI 맞춤 설교 만들기',
                    style: notoSansKr.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textColor,
                    ),
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(height: 32),
            
            // 콘텐츠 영역 (스크롤)
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [

              // 1. 주제 선택 (필수)
              _buildSectionTitle('어떤 주제로 말씀을 들을까요? (필수)'),
              _buildChoiceGroup<String>(
                items: _topics,
                selectedItem: _selectedTopic,
                onSelected: (val) => setState(() => _selectedTopic = val),
              ),
              const SizedBox(height: 24),

              // 2. 상황 선택 (선택)
              _buildSectionTitle('지금 어떤 상황이신가요? (선택)'),
              _buildChoiceGroup<String?>(
                items: _situations,
                selectedItem: _selectedSituation,
                onSelected: (val) => setState(() => _selectedSituation = val == _selectedSituation ? null : val),
              ),
              const SizedBox(height: 24),

              // 3. 설교 길이 (필수)
              _buildSectionTitle('설교 길이를 정해주세요 (필수)'),
              _buildChoiceGroup<String>(
                items: _lengths,
                selectedItem: _selectedLength,
                onSelected: (val) => setState(() => _selectedLength = val),
              ),
              const SizedBox(height: 24),

              // 4. 설교 톤 (선택)
              _buildSectionTitle('어떤 말투가 좋으신가요? (선택)'),
              _buildChoiceGroup<String?>(
                items: _tones,
                selectedItem: _selectedTone,
                onSelected: (val) => setState(() => _selectedTone = val == _selectedTone ? null : val),
              ),
              const SizedBox(height: 24),

              // 5. 키워드 (선택)
              _buildSectionTitle('추가하고 싶은 키워드가 있나요? (선택)'),
              TextField(
                controller: _keywordController,
                style: notoSansKr.copyWith(fontSize: 14),
                decoration: InputDecoration(
                  hintText: '예: 새 출발, 두려움, 감사 습관',
                  hintStyle: notoSansKr.copyWith(
                    color: AppTheme.textColor.withValues(alpha: 0.4),
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: AppTheme.secondaryColor.withValues(alpha: 0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 32),

              // 생성하기 버튼
              const SizedBox(height: 24),
              SizedBox(
                height: 60,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7F7FD5), Color(0xFF86A8E7)],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF7F7FD5).withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _handleGenerate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
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
              ),
            ],
          ),
        ),
      ),
    ],
  ),
),
);
}

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.notoSansKr(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: AppTheme.textColor,
        ),
      ),
    );
  }

  Widget _buildChoiceGroup<T>({
    required List<T> items,
    required T selectedItem,
    required Function(T) onSelected,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        final isSelected = item == selectedItem;
        return ChoiceChip(
          label: Text(
            item.toString(),
            style: GoogleFonts.notoSansKr(
              fontSize: 13,
              color: isSelected ? Colors.white : AppTheme.textColor.withValues(alpha: 0.7),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          selected: isSelected,
          onSelected: (_) => onSelected(item),
          selectedColor: const Color(0xFF7F7FD5),
          backgroundColor: AppTheme.secondaryColor.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: isSelected ? Colors.transparent : Colors.grey.withValues(alpha: 0.1),
            ),
          ),
          showCheckmark: false,
        );
      }).toList(),
    );
  }
}
