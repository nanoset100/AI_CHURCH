import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/public_sermon_model.dart';
import '../../widgets/prayer_editor.dart';
import '../../widgets/today_sermon_card.dart';

class SermonDetailScreen extends StatelessWidget {
  final PublicSermonModel sermon;
  const SermonDetailScreen({super.key, required this.sermon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('말씀 보기'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () => Share.share(
              '📖 ${sermon.title}\n${sermon.bibleVerse} · ${sermon.pastor}'
              '\n\n${sermon.summary}\n\n✏️ ${sermon.application}',
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TodaySermonCard(sermon: sermon),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                        onPressed: () => writePrayer(context, sermon),
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('이 말씀으로 기도 쓰기')))),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
