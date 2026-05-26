import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/public_sermon_model.dart';
import '../services/sermon_service.dart';

class SermonProvider extends ChangeNotifier {
  PublicSermonModel?       _todaySermon;
  List<PublicSermonModel>  _weekSermons    = [];
  List<PublicSermonModel>  _searchResults  = [];
  bool                     _isTodayLoading  = false;
  bool                     _isSearchLoading = false;
  String?                  _error;

  // 검색어 + 지역 필터 상태 관리
  String  _currentKeyword = '';
  String  _currentRegion  = '전체';
  Timer?  _debounce;

  PublicSermonModel?       get todaySermon    => _todaySermon;
  List<PublicSermonModel>  get weekSermons    => _weekSermons;
  List<PublicSermonModel>  get searchResults  => _searchResults;
  bool                     get isTodayLoading  => _isTodayLoading;
  bool                     get isSearchLoading => _isSearchLoading;
  // SearchScreen에서 isLoading으로 접근하도록 alias 제공
  bool                     get isLoading       => _isSearchLoading;
  String?                  get error           => _error;

  // ── 오늘의 말씀 로드 ─────────────────────────────
  Future<void> loadToday() async {
    _isTodayLoading = true;
    _error = null;
    notifyListeners();

    _todaySermon = await SermonService.getTodaySermon();
    _weekSermons = await SermonService.getWeekSermons();

    // Firebase에 데이터 없으면 Mock 폴백
    if (_todaySermon == null) {
      final mocks = SermonService.getMockData();
      _todaySermon = mocks.first;
      _weekSermons = mocks;
    }

    _isTodayLoading = false;
    notifyListeners();
  }

  // ── 검색 (300ms 디바운스) ──────────────────────────
  Future<void> search(String keyword) async {
    _currentKeyword = keyword;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _applyFilters();
    });
  }

  // ── 지역 필터 ─────────────────────────────────────
  Future<void> filterByRegion(String region) async {
    _currentRegion = region;
    await _applyFilters();
  }

  // ── 복합 필터 적용 (검색어 + 지역) ───────────────────
  Future<void> _applyFilters() async {
    _isSearchLoading = true;
    notifyListeners();

    List<PublicSermonModel> base;

    if (_currentRegion == '전체') {
      base = await SermonService.getRecentSermons(limit: 200);
    } else {
      base = await SermonService.getByRegion(_currentRegion);
    }

    if (_currentKeyword.trim().isNotEmpty) {
      final q = _currentKeyword.toLowerCase();
      base = base.where((s) =>
        s.title.toLowerCase().contains(q)      ||
        s.bibleVerse.toLowerCase().contains(q) ||
        s.pastor.toLowerCase().contains(q)     ||
        s.churchName.toLowerCase().contains(q) ||
        s.region.toLowerCase().contains(q)
      ).toList();
    }

    _searchResults = base;
    _isSearchLoading = false;
    notifyListeners();
  }

  // ── 최근 목록 (초기 로드) ──────────────────────────
  Future<void> loadRecent() async {
    _currentKeyword = '';
    _isSearchLoading = true;
    notifyListeners();

    _searchResults = await SermonService.getRecentSermons();
    if (_searchResults.isEmpty) {
      _searchResults = SermonService.getMockData();
    }

    _isSearchLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
