import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AudioService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioPlayer _bgmPlayer = AudioPlayer();
  
  AudioService() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.completed || state == PlayerState.stopped) {
        _bgmPlayer.stop();
      }
    });
  }
  
  // 현재 재생 상태
  PlayerState get playerState => _audioPlayer.state;
  Stream<PlayerState> get onPlayerStateChanged => _audioPlayer.onPlayerStateChanged;

  // 오디오 진행 상태 스트림
  Stream<Duration> get onPositionChanged => _audioPlayer.onPositionChanged;
  Stream<Duration> get onDurationChanged => _audioPlayer.onDurationChanged;

  /// Supabase Edge Functions를 호출하여 TTS 생성
  Future<Uint8List?> generateAudio(String text, {bool isMale = true}) async {
    final voice = isMale ? 'onyx' : 'nova';

    try {
      final response = await Supabase.instance.client.functions.invoke(
        'generate-tts',
        body: {
          'text': text,
          'voice': voice,
        },
      );

      if (response.status == 200 && response.data != null) {
        // Edge Functions에서 바이너리(Blob)로 반환된 데이터를 Uint8List로 변환
        if (response.data is List<int>) {
          return Uint8List.fromList(response.data as List<int>);
        } else if (response.data is Uint8List) {
          return response.data as Uint8List;
        }
        return null;
      } else if (response.status == 401) {
        // ✅ 401 전용 처리: 강제 로그아웃 트리거하여 자동 리다이렉션 유도
        await Supabase.instance.client.auth.signOut();
        debugPrint('Edge Function TTS Error: Unauthorized (401)');
        return null;
      } else {
        debugPrint('Edge Function TTS Error: ${response.status} - ${response.data}');
        return null;
      }
    } catch (e) {
      debugPrint('TTS Generation Exception: $e');
      return null;
    }
  }

  /// 바이트 데이터를 기기 로컬 스토리지에 저장하고 경로 반환
  Future<String?> saveAudioFile(Uint8List audioBytes, String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final folderPath = '${directory.path}/sermons';
      final folder = Directory(folderPath);
      if (!await folder.exists()) {
        await folder.create(recursive: true);
      }
      
      final filePath = '$folderPath/$fileName.mp3';
      final file = File(filePath);
      await file.writeAsBytes(audioBytes);
      return filePath;
    } catch (e) {
      debugPrint('Audio Save Exception: $e');
      return null;
    }
  }

  /// 바이트 데이터를 재생
  Future<void> playBytes(Uint8List audioBytes) async {
    await _playBgm();
    await _audioPlayer.play(BytesSource(audioBytes));
  }

  Future<void> _playBgm() async {
    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgmPlayer.setVolume(0.15);
    await _bgmPlayer.play(AssetSource('audio/bgm.mp3'));
  }

  /// 로컬 파일 오디오 재생
  Future<void> playFile(String filePath) async {
    await _playBgm();
    await _audioPlayer.play(DeviceFileSource(filePath));
  }

  /// 재생 일시정지
  Future<void> pause() async {
    await _bgmPlayer.pause();
    await _audioPlayer.pause();
  }

  /// 재생 재개
  Future<void> resume() async {
    await _bgmPlayer.resume();
    await _audioPlayer.resume();
  }

  /// 재생 정지
  Future<void> stop() async {
    await _bgmPlayer.stop();
    await _audioPlayer.stop();
  }

  /// 처음부터 다시 재생
  Future<void> replay() async {
    await _audioPlayer.seek(Duration.zero);
    await _playBgm();
    await _audioPlayer.resume();
  }
  
  /// 특정 위치로 탐색
  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  /// 자원 해제
  Future<void> dispose() async {
    await _bgmPlayer.dispose();
    await _audioPlayer.dispose();
  }
}
