import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// 공개 채널과 연결 앱 주소를 한곳에서 관리합니다.
class FaithLinkService {
  static final shorts = Uri.https('www.youtube.com', '/@AI가나안교회/shorts');
  static final bibleStore = Uri.https('play.google.com', '/store/apps/details',
      {'id': 'com.bible_app.king_beginner_bible'});
  static final bibleAppleStore =
      Uri.https('apps.apple.com', '/kr/app/id6760569924');

  static Future<bool> openShorts() => _open(shorts);

  static Future<bool> openBible() async {
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      return _open(bibleAppleStore);
    }
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      if (await _open(
          Uri.parse('android-app://com.bible_app.king_beginner_bible'))) {
        return true;
      }
      return _open(bibleStore);
    }
    return _open(bibleStore);
  }

  static Future<bool> _open(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}
