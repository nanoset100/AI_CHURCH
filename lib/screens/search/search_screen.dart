import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/sermon_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/sermon_list_tile.dart';
import 'sermon_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();
  String _selectedRegion = '전체';
  static const _regions = [
    '전체',
    '서울',
    '경기',
    '인천',
    '부산',
    '대구',
    '광주',
    '전남',
    '전북',
    '경남',
    '경북',
    '충청',
    '강원',
    '제주'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SermonProvider>().loadRecent();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SermonProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('말씀 찾기')),
      body: Column(
        children: [
          // 검색바
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _ctrl,
              decoration: InputDecoration(
                hintText: '성경 본문, 설교 제목, 목사님, 지역...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _ctrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _ctrl.clear();
                          context.read<SermonProvider>().search('');
                        })
                    : null,
                filled: true,
                fillColor: AppTheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.divider),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.divider),
                ),
              ),
              onChanged: (v) => context.read<SermonProvider>().search(v),
            ),
          ),

          // 지역 필터 칩
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              itemCount: _regions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final r = _regions[i];
                final selected = _selectedRegion == r;
                return FilterChip(
                  label: Text(r),
                  selected: selected,
                  onSelected: (_) {
                    setState(() => _selectedRegion = r);
                    context.read<SermonProvider>().filterByRegion(r);
                  },
                  selectedColor: AppTheme.primary.withValues(alpha: 0.15),
                  checkmarkColor: AppTheme.primary,
                );
              },
            ),
          ),

          if (provider.searchMessage != null && !provider.isSearchLoading)
            TextButton.icon(
                onPressed: provider.loadRecent,
                icon: const Icon(Icons.refresh),
                label: Text('${provider.searchMessage} 다시 조회')),
          // 결과 목록
          Expanded(
            child: provider.isSearchLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppTheme.primary))
                : provider.searchResults.isEmpty
                    ? Center(
                        child: provider.searchMessage == null
                            ? const Text('검색 결과가 없습니다',
                                style: TextStyle(color: AppTheme.textLight))
                            : null)
                    : ListView.builder(
                        itemCount: provider.searchResults.length,
                        itemBuilder: (_, i) => SermonListTile(
                          sermon: provider.searchResults[i],
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SermonDetailScreen(
                                  sermon: provider.searchResults[i]),
                            ),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
