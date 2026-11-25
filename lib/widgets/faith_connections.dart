import 'package:flutter/material.dart';
import '../services/faith_link_service.dart';

class FaithConnections extends StatelessWidget {
  final VoidCallback onPrayerTap;
  const FaithConnections({super.key, required this.onPrayerTap});

  Future<void> _open(
      BuildContext context, Future<bool> Function() action, String name) async {
    if (!await action() && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$name 연결을 열지 못했어요. 다시 시도해 주세요.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final actions = [
      (label: '나의 기도제목', icon: Icons.favorite_border, tap: onPrayerTap),
      (
        label: '왕초보성경통독',
        icon: Icons.menu_book_outlined,
        tap: () => _open(context, FaithLinkService.openBible, '왕초보성경통독')
      ),
      (
        label: '유튜브 쇼츠',
        icon: Icons.play_circle_outline,
        tap: () => _open(context, FaithLinkService.openShorts, '유튜브')
      ),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: LayoutBuilder(builder: (context, bounds) {
        final stacked =
            bounds.maxWidth / 3 < MediaQuery.textScalerOf(context).scale(105);
        return Wrap(spacing: 8, runSpacing: 8, children: [
          for (final action in actions)
            SizedBox(
                width: stacked ? bounds.maxWidth : (bounds.maxWidth - 16) / 3,
                child: OutlinedButton(
                    onPressed: action.tap,
                    style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 12),
                        minimumSize: const Size(48, 48),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    child: Flex(
                        direction: stacked ? Axis.horizontal : Axis.vertical,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(action.icon),
                          SizedBox(
                              width: stacked ? 8 : 0, height: stacked ? 0 : 6),
                          Text(action.label,
                              textAlign: TextAlign.center,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                        ]))),
        ]);
      }),
    );
  }
}
