import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:ai_canaan_church/theme/app_theme.dart';
import 'package:ai_canaan_church/providers/prayer_provider.dart';

class PrayerRequestsScreen extends StatefulWidget {
  const PrayerRequestsScreen({super.key});

  @override
  State<PrayerRequestsScreen> createState() => _PrayerRequestsScreenState();
}

class _PrayerRequestsScreenState extends State<PrayerRequestsScreen> {
  final _titleController = TextEditingController();
  String _selectedCategory = '개인';

  final List<String> _categories = ['개인', '가족', '직장', '교회', '건강', '기타'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PrayerProvider>(context, listen: false).fetchPrayerRequests();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _showAddPrayerDialog() {
    final notoSansKr = GoogleFonts.notoSansKr();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateBuilder) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(
                '새로운 기도제목 추가',
                style: notoSansKr.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: '기도제목을 입력하세요',
                      hintStyle: notoSansKr.copyWith(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '카테고리 선택',
                    style: notoSansKr.copyWith(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _categories.map((category) {
                      final isSelected = _selectedCategory == category;
                      return ChoiceChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setStateBuilder(() {
                              _selectedCategory = category;
                            });
                          }
                        },
                        selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                        labelStyle: notoSansKr.copyWith(
                          color: isSelected ? AppTheme.primaryColor : Colors.grey[700],
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('취소', style: notoSansKr.copyWith(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final title = _titleController.text.trim();
                    if (title.isNotEmpty) {
                      final provider = Provider.of<PrayerProvider>(context, listen: false);
                      await provider.addPrayerRequest(title, _selectedCategory);
                      _titleController.clear();
                      _selectedCategory = '개인';
                      if (context.mounted) Navigator.of(context).pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('추가', style: notoSansKr.copyWith(color: Colors.white)),
                ),
              ],
            );
          }
        );
      },
    ).then((_) {
      // 다이얼로그 닫힐 때 초기화
      _titleController.clear();
      _selectedCategory = '개인';
    });
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case '가족':
        return Colors.orange.shade300;
      case '직장':
        return Colors.blue.shade300;
      case '건강':
        return Colors.red.shade300;
      case '교회':
        return Colors.green.shade300;
      case '개인':
        return Colors.purple.shade300;
      default:
        return Colors.grey.shade400;
    }
  }

  @override
  Widget build(BuildContext context) {
    final notoSansKr = GoogleFonts.notoSansKr();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          '나의 기도제목 관리',
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
      body: Consumer<PrayerProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.prayerRequests.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
          }

          if (provider.errorMessage != null && provider.prayerRequests.isEmpty) {
            return Center(
              child: Text(
                provider.errorMessage!,
                style: notoSansKr.copyWith(color: Colors.red),
              ),
            );
          }

          if (provider.prayerRequests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🙏', style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 16),
                  Text(
                    '앗, 아직 작성된 기도제목이 없네요!',
                    style: notoSansKr.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '오른쪽 아래 + 버튼을 눌러 첫 기도를 남겨보세요.',
                    style: notoSansKr.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.prayerRequests.length,
            itemBuilder: (context, index) {
              final prayer = provider.prayerRequests[index];
              return Dismissible(
                key: Key(prayer.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) {
                  provider.deletePrayerRequest(prayer.id);
                },
                child: Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: prayer.isAnswered ? Colors.green.shade200 : Colors.grey.shade200,
                    ),
                  ),
                  color: prayer.isAnswered ? Colors.green.shade50 : Colors.white,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(prayer.category),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        prayer.category,
                        style: notoSansKr.copyWith(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(
                      prayer.title,
                      style: notoSansKr.copyWith(
                        fontWeight: FontWeight.bold,
                        decoration: prayer.isAnswered ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    trailing: Switch(
                      value: prayer.isAnswered,
                      onChanged: (val) {
                        provider.toggleAnsweredStatus(prayer.id, prayer.isAnswered);
                      },
                      activeColor: Colors.green,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPrayerDialog,
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
