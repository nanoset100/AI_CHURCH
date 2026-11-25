import 'dart:js_interop';

import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

import 'sermon_audio_controls.dart';

class SermonWebAudio extends StatefulWidget {
  final String audioUrl;
  final bool compact;

  const SermonWebAudio({
    super.key,
    required this.audioUrl,
    required this.compact,
  });

  @override
  State<SermonWebAudio> createState() => _SermonWebAudioState();
}

class _SermonWebAudioState extends State<SermonWebAudio> {
  static const _mediaEvents = [
    'loadedmetadata',
    'durationchange',
    'timeupdate',
    'seeked',
    'play',
    'pause',
    'ended',
    'error',
  ];

  late final web.HTMLAudioElement _audio;
  late final JSFunction _onMediaEvent;
  bool _loading = false;
  bool _playFailed = false;

  @override
  void initState() {
    super.initState();
    _audio = web.HTMLAudioElement()..preload = 'metadata';
    _onMediaEvent = ((web.Event event) {
      if (mounted) setState(() {});
    }).toJS;
    for (final event in _mediaEvents) {
      _audio.addEventListener(event, _onMediaEvent);
    }
    // A media element can play these Storage URLs without requesting CORS.
    _audio.src = widget.audioUrl;
  }

  @override
  void dispose() {
    for (final event in _mediaEvents) {
      _audio.removeEventListener(event, _onMediaEvent);
    }
    _audio
      ..pause()
      ..removeAttribute('src')
      ..load();
    super.dispose();
  }

  Duration _readTime(double seconds) => seconds.isFinite && seconds > 0
      ? Duration(milliseconds: (seconds * 1000).round())
      : Duration.zero;

  Future<void> _toggle() async {
    if (!_audio.paused) {
      _audio.pause();
      return;
    }
    setState(() {
      _loading = true;
      _playFailed = false;
    });
    try {
      if (_audio.error != null) _audio.load();
      await _audio.play().toDart;
    } catch (_) {
      _playFailed = true;
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _seek(Duration position) {
    setState(() => _audio.currentTime = position.inMilliseconds / 1000);
  }

  void _stop() {
    _audio.pause();
    if (_audio.readyState > 0) _seek(Duration.zero);
  }

  @override
  Widget build(BuildContext context) {
    return SermonAudioControls(
      position: _readTime(_audio.currentTime),
      duration: _readTime(_audio.duration),
      isPlaying: !_audio.paused && !_audio.ended,
      isLoading: _loading,
      onToggle: _toggle,
      onStop: _loading ? null : _stop,
      onSeek: _seek,
      compact: widget.compact,
      error: _audio.error != null || _playFailed
          ? '설교 음성을 불러오지 못했어요. 다시 재생해 주세요.'
          : null,
    );
  }
}
