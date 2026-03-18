import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:ai_canaan_church/theme/app_theme.dart';
import 'package:ai_canaan_church/providers/sermon_provider.dart';
import 'package:ai_canaan_church/screens/saved_sermon_detail_screen.dart';

class SavedSermonsListScreen extends StatelessWidget {
  const SavedSermonsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notoSansKr = GoogleFonts.notoSansKr();
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          '보관된 설교 전체보기',
          style: notoSansKr.copyWith(
            color: AppTheme.textColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textColor),
        centerTitle: true,
      ),
      body: Consumer<SermonProvider>(
        builder: (context, sermonProvider, child) {
          final savedSermons = sermonProvider.savedSermons;
          
          if (savedSermons.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   const Text(
                    '💾',
                    style: TextStyle(fontSize: 48),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '저장된 설교가 없습니다.',
                    style: notoSansKr.copyWith(
                      fontSize: 16,
                      color: AppTheme.textColor.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            );
          }
          
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: savedSermons.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final sermon = savedSermons[index];
              return _buildSermonTile(context, sermon, notoSansKr);
            },
          );
        },
      ),
    );
  }

  Widget _buildSermonTile(BuildContext context, dynamic sermon, TextStyle baseStyle) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SavedSermonDetailScreen(sermon: sermon),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: AppTheme.primaryColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sermon.title,
                    style: baseStyle.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: AppTheme.textColor.withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        sermon.formattedDate,
                        style: baseStyle.copyWith(
                          fontSize: 13,
                          color: AppTheme.textColor.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 24),
              color: Colors.red[300],
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text(
                      '설교 삭제',
                      style: baseStyle.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    content: Text(
                      '이 보관된 설교를 완전히 삭제하시겠습니까?',
                      style: baseStyle.copyWith(fontSize: 14),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(
                          '취소', 
                          style: baseStyle.copyWith(color: AppTheme.textColor)
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text(
                          '삭제',
                          style: baseStyle.copyWith(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );

                if (confirm == true && context.mounted) {
                  await Provider.of<SermonProvider>(context, listen: false)
                      .deleteSermon(sermon.id);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
