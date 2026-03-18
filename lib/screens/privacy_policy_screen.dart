import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ai_canaan_church/theme/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notoSansKr = GoogleFonts.notoSansKr();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          '개인정보처리방침',
          style: notoSansKr.copyWith(
            color: AppTheme.textColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI 가나안교회 개인정보처리방침',
              style: notoSansKr.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '최종 업데이트: 2026년 3월',
              style: notoSansKr.copyWith(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            _section(
              notoSansKr,
              '1. 수집하는 개인정보',
              '서비스 이용을 위해 다음 정보를 수집합니다.\n\n'
              '• 이메일 주소 (회원가입 및 로그인)\n'
              '• 표시 이름 (닉네임)\n'
              '• 앱 사용 기록 (저장된 설교, 기도제목, 성경 읽기 기록)',
            ),
            _section(
              notoSansKr,
              '2. 개인정보의 이용 목적',
              '수집된 개인정보는 다음 목적으로만 사용됩니다.\n\n'
              '• 회원 식별 및 서비스 제공\n'
              '• AI 맞춤 설교 생성\n'
              '• 개인 영적 기록 저장 및 관리',
            ),
            _section(
              notoSansKr,
              '3. 개인정보의 보관 및 파기',
              '개인정보는 서비스 이용 기간 동안 보관되며, '
              '회원 탈퇴 시 즉시 파기됩니다. '
              '법령에 의해 보관이 필요한 경우 해당 기간 동안 보관 후 파기합니다.',
            ),
            _section(
              notoSansKr,
              '4. 제3자 제공',
              'AI 설교 생성을 위해 입력하신 키워드 및 주제가 '
              'AI 서비스 제공자에게 전달될 수 있습니다. '
              '개인을 식별할 수 있는 정보는 제3자에게 제공되지 않습니다.',
            ),
            _section(
              notoSansKr,
              '5. 이용자의 권리',
              '이용자는 언제든지 다음 권리를 행사할 수 있습니다.\n\n'
              '• 개인정보 열람 요청\n'
              '• 개인정보 수정 요청\n'
              '• 개인정보 삭제 요청 (회원 탈퇴)\n\n'
              '요청은 앱 내 프로필 메뉴 또는 아래 연락처로 할 수 있습니다.',
            ),
            _section(
              notoSansKr,
              '6. 보안',
              'Supabase의 암호화된 데이터베이스와 '
              'Row Level Security(RLS) 정책을 통해 '
              '이용자의 데이터를 안전하게 보호합니다.',
            ),
            _section(
              notoSansKr,
              '7. 문의',
              '개인정보 처리에 관한 문의는 아래로 연락해주세요.\n\n'
              '• 개발사: 나너셋\n'
              '• 이메일: nanoset@naver.com',
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _section(TextStyle base, String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: base.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: base.copyWith(
              fontSize: 14,
              color: const Color(0xFF555555),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
