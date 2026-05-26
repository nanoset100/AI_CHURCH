import 'package:flutter/material.dart';

/// 환영 팝업 — 매번 표시 (시연용)
/// 시연 종료 후 → _intervalDays = 7 주기 버전으로 교체 예정
class WelcomePopup {
  static Future<void> showIfNeeded(BuildContext context) async {
    if (!context.mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      builder: (_) => const _WelcomeDialog(),
    );
  }
}

class _WelcomeDialog extends StatelessWidget {
  const _WelcomeDialog();

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          height: screenH * 0.82,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ── 배경 이미지 ──
              Image.asset(
                'assets/images/welcome_popup.png',
                fit: BoxFit.cover,
              ),

              // ── 하단 그라데이션 오버레이 (버튼 가독성) ──
              Positioned(
                left: 0, right: 0, bottom: 0,
                height: 100,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black54],
                    ),
                  ),
                ),
              ),

              // ── 닫기 버튼 ──
              Positioned(
                left: 20, right: 20, bottom: 24,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5C3D1E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    '오늘 말씀 받아보기',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
