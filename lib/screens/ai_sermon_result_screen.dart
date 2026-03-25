import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:ai_canaan_church/theme/app_theme.dart';
import 'package:ai_canaan_church/models/sermon.dart';
import 'package:ai_canaan_church/providers/sermon_provider.dart';
import 'package:ai_canaan_church/screens/home_screen.dart';
import 'package:ai_canaan_church/services/audio_service.dart';
import 'package:ai_canaan_church/providers/activity_provider.dart';
import 'package:share_plus/share_plus.dart';

/// AI 설교 결과 화면
class AiSermonResultScreen extends StatefulWidget {
  final Sermon sermon;

  const AiSermonResultScreen({
    super.key,
    required this.sermon,
  });

  @override
  State<AiSermonResultScreen> createState() => _AiSermonResultScreenState();
}

class _AiSermonResultScreenState extends State<AiSermonResultScreen> {
  final AudioService _audioService = AudioService();
  bool _isLoadingAudio = false;
  bool _isMaleVoice = true; // true: Onyx(남성), false: Nova(여성)
  bool _hasAudioLoaded = false;
  PlayerState _playerState = PlayerState.stopped;
  Uint8List? _generatedAudioBytes;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _audioService.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _playerState = state;
        });
      }
    });

    _audioService.onPositionChanged.listen((pos) {
      if (mounted) {
        setState(() {
          _position = pos;
        });
      }
    });

    _audioService.onDurationChanged.listen((dur) {
      if (mounted) {
        setState(() {
          _duration = dur;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }

  void _shareSermon() {
    final sermonText = '''
💌 AI 가나안교회에서 온 편지 💌

[${widget.sermon.topic}] ${widget.sermon.title}
${widget.sermon.verse}

${widget.sermon.content}

🙏 언제 어디서나 주님과 동행하세요.
''';
    SharePlus.instance.share(ShareParams(text: sermonText));
  }

  Future<void> _handleSave(BuildContext context) async {
    final sermonProvider = Provider.of<SermonProvider>(context, listen: false);
    
    String? localAudioPath;
    if (_generatedAudioBytes != null) {
      final fileName = 'sermon_${widget.sermon.id}_${_isMaleVoice ? "m" : "f"}';
      localAudioPath = await _audioService.saveAudioFile(_generatedAudioBytes!, fileName);
    }

    final sermonToSave = Sermon(
      id: widget.sermon.id,
      title: widget.sermon.title,
      verse: widget.sermon.verse,
      content: widget.sermon.content,
      userPrompt: widget.sermon.userPrompt,
      createdAt: widget.sermon.createdAt,
      topic: widget.sermon.topic,
      situation: widget.sermon.situation,
      length: widget.sermon.length,
      tone: widget.sermon.tone,
      keyword: widget.sermon.keyword,
      audioUrl: localAudioPath,
    );

    final success = await sermonProvider.saveSermon(sermonToSave);

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '설교가 보관되었습니다!',
            style: GoogleFonts.notoSansKr(),
          ),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            sermonProvider.errorMessage ?? '설교 저장에 실패했습니다.',
            style: GoogleFonts.notoSansKr(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _toggleAudio() async {
    // 이미 로드된 오디오가 있다면 재생/일시정지 토글
    if (_hasAudioLoaded) {
      if (_playerState == PlayerState.playing) {
        await _audioService.pause();
      } else if (_playerState == PlayerState.completed) {
        await _audioService.replay();
      } else {
        await _audioService.resume();
      }
      return;
    }

    // 처음 재생하는 경우 API 호출
    setState(() {
      _isLoadingAudio = true;
    });

    // 읽어줄 텍스트 조합
    final textToRead = '${widget.sermon.title}. ${widget.sermon.verse}. ${widget.sermon.content}';

    try {
      final audioBytes = await _audioService.generateAudio(textToRead, isMale: _isMaleVoice);
      if (audioBytes != null) {
        _generatedAudioBytes = audioBytes;
        await _audioService.playBytes(audioBytes);
        if (mounted) {
          Provider.of<ActivityProvider>(context, listen: false).logWorship(widget.sermon.title);
          setState(() {
            _hasAudioLoaded = true;
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('음성 생성에 실패했습니다. API 키를 확인해주세요.', style: GoogleFonts.notoSansKr()),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingAudio = false;
        });
      }
    }
  }

  Future<void> _stopAudio() async {
    await _audioService.stop();
  }

  void _onVoiceTypeChanged(bool isMale) {
    if (_isMaleVoice == isMale) return;
    setState(() {
      _isMaleVoice = isMale;
      _hasAudioLoaded = false; // 목소리가 바뀌면 새로 생성해야 함
      _playerState = PlayerState.stopped;
    });
    _audioService.stop();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final notoSansKr = GoogleFonts.notoSansKr();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          color: AppTheme.textColor,
          onPressed: () {
            Provider.of<SermonProvider>(context, listen: false).clearCurrentSermon();
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          },
        ),
        title: Text(
          'AI 맞춤 설교',
          style: notoSansKr.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textColor,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            color: AppTheme.textColor,
            onPressed: _shareSermon,
            tooltip: '은혜 나누기(공유)',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 배지
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'AI 맞춤 설교',
                  style: notoSansKr.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 오디오 플레이어 컨트롤 패널
            _buildAudioPlayerPanel(notoSansKr),
            const SizedBox(height: 16),

            // 제목
            Text(
              widget.sermon.title,
              style: notoSansKr.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                height: 1.4,
                color: AppTheme.textColor,
              ),
            ),
            const SizedBox(height: 12),

            // 성경 구절
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.secondaryColor.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.primaryColor.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                widget.sermon.verse,
                style: notoSansKr.copyWith(
                  fontSize: 14,
                  color: AppTheme.textColor,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 설교 본문
            Text(
              widget.sermon.content,
              style: notoSansKr.copyWith(
                fontSize: 16,
                height: 1.8,
                color: AppTheme.textColor,
              ),
            ),
            const SizedBox(height: 32),

            // 사용자 고민 (작은 글씨로)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '"\${widget.sermon.userPrompt}"',
                      style: notoSansKr.copyWith(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 버튼 영역
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Provider.of<SermonProvider>(context, listen: false).clearCurrentSermon();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      side: BorderSide(color: AppTheme.primaryColor),
                    ),
                    child: Text(
                      '다시 만들기',
                      style: notoSansKr.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _handleSave(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '보관하기',
                          style: notoSansKr.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text('💾', style: TextStyle(fontSize: 18)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioPlayerPanel(TextStyle notoSansKr) {
    bool isPlaying = _playerState == PlayerState.playing;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              Text(
                '설교 듣기',
                style: notoSansKr.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor,
                ),
              ),
              // 성우 선택 토글
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  GestureDetector(
                    onTap: () => _onVoiceTypeChanged(true),
                    child: Chip(
                      visualDensity: VisualDensity.compact,
                      label: Text('👨 남성', style: TextStyle(fontSize: 12)),
                      backgroundColor: _isMaleVoice ? AppTheme.primaryColor.withValues(alpha: 0.2) : Colors.grey.shade200,
                      labelStyle: TextStyle(
                        color: _isMaleVoice ? AppTheme.primaryColor : Colors.grey.shade700,
                        fontWeight: _isMaleVoice ? FontWeight.bold : FontWeight.normal,
                      ),
                      side: BorderSide.none,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _onVoiceTypeChanged(false),
                    child: Chip(
                      visualDensity: VisualDensity.compact,
                      label: Text('👩 여성', style: TextStyle(fontSize: 12)),
                      backgroundColor: !_isMaleVoice ? AppTheme.primaryColor.withValues(alpha: 0.2) : Colors.grey.shade200,
                      labelStyle: TextStyle(
                        color: !_isMaleVoice ? AppTheme.primaryColor : Colors.grey.shade700,
                        fontWeight: !_isMaleVoice ? FontWeight.bold : FontWeight.normal,
                      ),
                      side: BorderSide.none,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress Bar
          if (_hasAudioLoaded || _isLoadingAudio)
            Column(
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                    activeTrackColor: AppTheme.primaryColor,
                    inactiveTrackColor: Colors.grey.shade200,
                    thumbColor: AppTheme.primaryColor,
                  ),
                  child: Slider(
                    min: 0,
                    max: _duration.inSeconds.toDouble() > 0 ? _duration.inSeconds.toDouble() : 1.0,
                    value: _position.inSeconds.toDouble().clamp(0.0, _duration.inSeconds.toDouble() > 0 ? _duration.inSeconds.toDouble() : 1.0),
                    onChanged: (value) {
                      if (_hasAudioLoaded) {
                        _audioService.seek(Duration(seconds: value.toInt()));
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(_position),
                        style: notoSansKr.copyWith(fontSize: 12, color: Colors.grey.shade600),
                      ),
                      Text(
                        _formatDuration(_duration),
                        style: notoSansKr.copyWith(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 재생/일시정지 버튼
              InkWell(
                onTap: _isLoadingAudio ? null : _toggleAudio,
                borderRadius: BorderRadius.circular(40),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primaryColor,
                  ),
                  child: _isLoadingAudio
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Icon(
                          isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 28,
                        ),
                ),
              ),
              const SizedBox(width: 24),
              // 정지 버튼
              InkWell(
                onTap: (_hasAudioLoaded && isPlaying) ? _stopAudio : null,
                borderRadius: BorderRadius.circular(40),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (_hasAudioLoaded && isPlaying) ? Colors.red.shade400 : Colors.grey.shade300,
                  ),
                  child: const Icon(
                    Icons.stop,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
