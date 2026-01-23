import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // PRD 기준 색상
  static const Color primaryColor = Color(0xFF4A90E2); // 신뢰감 있는 파란색
  static const Color secondaryColor = Color(0xFFF5F5DC); // 따뜻한 베이지
  static const Color textColor = Color(0xFF333333);
  static const Color backgroundColor = Color(0xFFFAFAFA);

  static ThemeData get lightTheme {
    // Noto Sans KR 폰트 강제 로드
    final notoSansKr = GoogleFonts.notoSansKr();
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: backgroundColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      // 전역 폰트 강제 설정
      fontFamily: notoSansKr.fontFamily,
      // 모든 텍스트 스타일에 한글 폰트 강제 적용
      textTheme: GoogleFonts.notoSansKrTextTheme(
        ThemeData.light().textTheme,
      ).copyWith(
        displayLarge: GoogleFonts.notoSansKr(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        displayMedium: GoogleFonts.notoSansKr(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        bodyLarge: GoogleFonts.notoSansKr(
          fontSize: 16,
          color: textColor,
        ),
        bodyMedium: GoogleFonts.notoSansKr(
          fontSize: 14,
          color: textColor,
        ),
      ),
    );
  }
}
