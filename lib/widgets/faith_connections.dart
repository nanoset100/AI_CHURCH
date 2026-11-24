import 'package:flutter/material.dart';
import '../services/faith_link_service.dart';
import '../theme/app_theme.dart';

class FaithConnections extends StatelessWidget {
  final VoidCallback onPrayerTap;
  const FaithConnections({super.key, required this.onPrayerTap});

  Future<void> _open(BuildContext context, Future<bool> Function() action,
      String message) async {
    final opened = await action();
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('짧은 말씀으로 만나요',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Material(
            color: const Color(0xFF204A73),
            borderRadius: BorderRadius.circular(20),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => _open(context, FaithLinkService.openShorts,
                  '유튜브를 열지 못했습니다. 잠시 후 다시 시도해 주세요.'),
              child: const Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.play_circle_fill_rounded,
                        color: Colors.white, size: 48),
                    SizedBox(height: 16),
                    Text('하루 잠깐, 말씀 한 편',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 23,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('AI 가나안교회의 짧은 말씀을 만나보세요.',
                        style: TextStyle(
                            color: Colors.white, fontSize: 16, height: 1.6)),
                    SizedBox(height: 20),
                    Row(children: [
                      Expanded(
                          child: Text('유튜브 쇼츠 보기',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold))),
                      Icon(Icons.open_in_new, color: Colors.white, size: 20),
                    ]),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          const Text('말씀과 함께하는 생활',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _ConnectionTile(
            icon: Icons.menu_book_rounded,
            title: '왕초보성경통독',
            description:
                '하루 한 장, 성경을 읽어요\nAndroid는 앱 또는 Google Play, iPhone은 App Store로 이동합니다.',
            external: true,
            onTap: () => _open(context, FaithLinkService.openBible,
                '왕초보성경통독을 열지 못했습니다. 잠시 후 다시 시도해 주세요.'),
          ),
          const SizedBox(height: 12),
          _ConnectionTile(
            icon: Icons.favorite_outline_rounded,
            title: '나의 기도제목',
            description: '마음에 담은 기도를 기록해요\n로그인 없이 이 기기에 저장됩니다.',
            onTap: onPrayerTap,
          ),
        ],
      ),
    );
  }
}

class _ConnectionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;
  final bool external;
  const _ConnectionTile(
      {required this.icon,
      required this.title,
      required this.description,
      required this.onTap,
      this.external = false});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surface,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppTheme.divider)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(children: [
            Icon(icon, size: 32, color: AppTheme.primary),
            const SizedBox(width: 16),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(description,
                      style: const TextStyle(
                          fontSize: 14, height: 1.6, color: AppTheme.textMid)),
                ])),
            const SizedBox(width: 8),
            Icon(external ? Icons.open_in_new : Icons.chevron_right,
                size: 20, color: AppTheme.primary),
          ]),
        ),
      ),
    );
  }
}
