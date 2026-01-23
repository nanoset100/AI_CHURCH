import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ai_canaan_church/theme/app_theme.dart';

/// 하단 네비게이션 바
class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  
  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final notoSansKr = GoogleFonts.notoSansKr();
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                notoSansKr: notoSansKr,
                icon: Icons.home,
                label: '홈',
                index: 0,
                isSelected: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _buildNavItem(
                notoSansKr: notoSansKr,
                icon: Icons.play_circle_outline,
                label: '예배',
                index: 1,
                isSelected: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              _buildNavItem(
                notoSansKr: notoSansKr,
                icon: Icons.menu_book_outlined,
                label: '성경',
                index: 2,
                isSelected: currentIndex == 2,
                onTap: () => onTap(2),
              ),
              _buildNavItem(
                notoSansKr: notoSansKr,
                icon: Icons.favorite_outline,
                label: '기도',
                index: 3,
                isSelected: currentIndex == 3,
                onTap: () => onTap(3),
              ),
              _buildNavItem(
                notoSansKr: notoSansKr,
                icon: Icons.more_horiz,
                label: '더보기',
                index: 4,
                isSelected: currentIndex == 4,
                onTap: () => onTap(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildNavItem({
    required TextStyle notoSansKr,
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryColor : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: notoSansKr.copyWith(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppTheme.primaryColor : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
