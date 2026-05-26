import 'package:flutter/material.dart';
import '../models/public_sermon_model.dart';
import '../theme/app_theme.dart';

class SermonListTile extends StatelessWidget {
  final PublicSermonModel sermon;
  final VoidCallback onTap;
  const SermonListTile({super.key, required this.sermon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppTheme.divider)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(sermon.formattedBroadcastDate,
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textLight)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(sermon.region,
                          style: const TextStyle(
                              fontSize: 11, color: AppTheme.primary)),
                    ),
                  ]),
                  const SizedBox(height: 4),
                  Text(sermon.title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text('${sermon.pastor} · ${sermon.churchName}',
                      style: const TextStyle(
                          fontSize: 13, color: AppTheme.textMid)),
                  const SizedBox(height: 4),
                  Text(sermon.summaryPreview,
                      style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textLight,
                          height: 1.4),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.textLight),
          ],
        ),
      ),
    );
  }
}
