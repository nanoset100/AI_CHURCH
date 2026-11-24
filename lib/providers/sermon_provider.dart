import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../models/public_sermon_model.dart';
import '../services/sermon_service.dart';

class SermonProvider extends ChangeNotifier {
  SermonProvider({this.fetch = SermonService.published});
  final Future<SermonPage> Function({required int limit, String? region}) fetch;

  List<PublicSermonModel> _weekSermons = [];
  List<PublicSermonModel> _searchResults = [];
  bool _isTodayLoading = false;
  bool _isSearchLoading = false;
  String? _homeMessage;
  String? _searchMessage;
  String _keyword = '';
  String _region = '전체';
  int _searchRequest = 0;
  Timer? _debounce;

  PublicSermonModel? get todaySermon => _weekSermons.firstOrNull;
  List<PublicSermonModel> get weekSermons => _weekSermons;
  List<PublicSermonModel> get searchResults => _searchResults;
  bool get isTodayLoading => _isTodayLoading;
  bool get isSearchLoading => _isSearchLoading;
  String? get homeMessage => _homeMessage;
  String? get searchMessage => _searchMessage;

  static const _offline = '저장된 말씀입니다. 최신 말씀을 확인하려면 다시 시도해 주세요.';
  static const _unavailable = '말씀을 불러오지 못했어요.';

  Future<void> loadToday() async {
    if (_isTodayLoading) return;
    _isTodayLoading = true;
    notifyListeners();
    try {
      final page = await fetch(limit: 7);
      if (!page.fromCache || page.sermons.isNotEmpty) {
        _weekSermons = page.sermons;
      }
      _homeMessage = page.fromCache
          ? (_weekSermons.isEmpty ? _unavailable : _offline)
          : null;
    } on FirebaseException catch (e) {
      if (e.code != 'unavailable' && e.code != 'deadline-exceeded') {
        _weekSermons = [];
      }
      _homeMessage = _weekSermons.isEmpty ? _unavailable : _offline;
    } catch (_) {
      // Firestore supplies previously fetched public documents through its disk cache.
      _weekSermons = [];
      _homeMessage = _unavailable;
    } finally {
      _isTodayLoading = false;
      notifyListeners();
    }
  }

  void search(String keyword) {
    _keyword = keyword;
    _debounce?.cancel();
    _searchRequest++;
    _debounce = Timer(const Duration(milliseconds: 300), loadRecent);
  }

  Future<void> filterByRegion(String region) {
    _region = region;
    return loadRecent();
  }

  Future<void> loadRecent() async {
    _debounce?.cancel();
    final request = ++_searchRequest;
    _isSearchLoading = true;
    notifyListeners();
    try {
      final q = _keyword.trim().toLowerCase();
      final page = await fetch(
          limit: _region == '전체' && q.isNotEmpty ? 200 : 30,
          region: _region == '전체' ? null : _region);
      if (request != _searchRequest) return;
      _searchResults = page.sermons
          .where((s) =>
              q.isEmpty ||
              [s.title, s.bibleVerse, s.pastor, s.churchName, s.region]
                  .any((field) => field.toLowerCase().contains(q)))
          .toList();
      _searchMessage = page.fromCache
          ? (page.sermons.isEmpty ? _unavailable : _offline)
          : null;
    } catch (_) {
      if (request != _searchRequest) return;
      _searchResults = [];
      _searchMessage = _unavailable;
    } finally {
      if (request == _searchRequest) {
        _isSearchLoading = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
