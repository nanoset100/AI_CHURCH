import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'sermon_audio_controls.dart';
import 'sermon_web_audio_stub.dart'
    if (dart.library.js_interop) 'sermon_web_audio.dart';

/// 설교 듣기 - 캐시된 오디오 URL을 재생하는 컴팩트 플레이어.
/// (유료 실시간 TTS API는 사용하지 않음. audioUrl 있을 때만 표시)
class SermonAudioPlayer extends StatelessWidget {
  final String audioUrl;
  final bool compact;
  const SermonAudioPlayer({
    super.key,
    required this.audioUrl,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return kIsWeb
        ? SermonWebAudio(
            key: ValueKey(audioUrl), audioUrl: audioUrl, compact: compact)
        : _NativeSermonAudioPlayer(audioUrl: audioUrl);
  }
}

class _NativeSermonAudioPlayer extends StatefulWidget {
  final String audioUrl;
  const _NativeSermonAudioPlayer({required this.audioUrl});

  @override
  State<_NativeSermonAudioPlayer> createState() => _SermonAudioPlayerState();
}

class _SermonAudioPlayerState extends State<_NativeSermonAudioPlayer> {
  final AudioPlayer _player = AudioPlayer();
  StreamSubscription<Duration>? _posSub;
  StreamSubscription<Duration>? _durSub;
  StreamSubscription<PlayerState>? _stateSub;

  PlayerState _state = PlayerState.stopped;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _loading = false;

  bool get _isPlaying => _state == PlayerState.playing;

  @override
  void initState() {
    super.initState();
    _posSub = _player.onPositionChanged.listen((d) {
      if (mounted) setState(() => _position = d);
    });
    _durSub = _player.onDurationChanged.listen((d) {
      if (mounted) setState(() => _duration = d);
    });
    _stateSub = _player.onPlayerStateChanged.listen((s) {
      if (mounted) setState(() => _state = s);
    });
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _durSub?.cancel();
    _stateSub?.cancel();
    _player.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    try {
      if (_isPlaying) {
        await _player.pause();
      } else if (_state == PlayerState.paused) {
        await _player.resume();
      } else {
        setState(() => _loading = true);
        await _player.play(UrlSource(widget.audioUrl));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오디오 오류: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _stop() async {
    await _player.stop();
    if (mounted) {
      setState(() {
        _state = PlayerState.stopped;
        _position = Duration.zero;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SermonAudioControls(
      position: _position,
      duration: _duration,
      isPlaying: _isPlaying,
      isLoading: _loading,
      onToggle: _toggle,
      onStop: _stop,
      onSeek: (target) {
        _player.seek(target);
        setState(() => _position = target);
      },
    );
  }
}
