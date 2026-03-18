import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:ai_canaan_church/theme/app_theme.dart';
import 'package:ai_canaan_church/providers/bible_provider.dart';
import 'package:ai_canaan_church/models/bible_verse.dart';
import 'package:ai_canaan_church/data/bible_data.dart';
import 'package:ai_canaan_church/providers/activity_provider.dart';
import 'package:audioplayers/audioplayers.dart';

class BibleReadingScreen extends StatefulWidget {
  final String? initialBookName;
  final int? initialChapter;

  const BibleReadingScreen({
    super.key,
    this.initialBookName,
    this.initialChapter,
  });

  @override
  State<BibleReadingScreen> createState() => _BibleReadingScreenState();
}

class _BibleReadingScreenState extends State<BibleReadingScreen> {
  late String _currentBook;
  late int _currentChapter;

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  String? _currentAudioUrl;
  bool _audioError = false;

  // 모든 성경책 리스트 평탄화
  final List<Map<String, dynamic>> _allBooks = [
    ...BibleData.oldTestament,
    ...BibleData.newTestament,
  ];

  int _getMaxChapters(String bookName) {
    final book = _allBooks.firstWhere((b) => b['name'] == bookName, orElse: () => _allBooks.first);
    return book['chapters'] as int;
  }

  bool _isNewTestament(String bookName) {
    return BibleData.newTestament.any((b) => b['name'] == bookName);
  }

  @override
  void initState() {
    super.initState();
    _currentBook = widget.initialBookName ?? '마태복음';
    _currentChapter = widget.initialChapter ?? 1;

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    _audioPlayer.onDurationChanged.listen((newDuration) {
      if (mounted) {
        setState(() {
          _duration = newDuration;
        });
      }
    });

    _audioPlayer.onPositionChanged.listen((newPosition) {
      if (mounted) {
        setState(() {
          _position = newPosition;
        });
      }
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
        });
      }
    });

    _loadCurrentChapter();
  }

  void _loadCurrentChapter() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BibleProvider>(context, listen: false)
          .fetchChapter(_currentBook, _currentChapter);
      Provider.of<ActivityProvider>(context, listen: false)
          .logBibleReading(_currentBook, _currentChapter);
    });
    // 오디오 상태 초기화
    if (_isPlaying) {
      _audioPlayer.stop();
    }
    setState(() {
      _position = Duration.zero;
      _duration = Duration.zero;
      _audioError = false;
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _toggleAudio() async {
    if (_currentAudioUrl == null) return;
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        // DB의 1.mp3 형태를 실제 Storage의 01.mp3 형태로 보정 (패딩 처리)
        String fixedUrl = _currentAudioUrl!;
        if (fixedUrl.contains('/')) {
          final parts = fixedUrl.split('/');
          final fileName = parts.last; // 예: 1.mp3
          if (fileName.contains('.') && !fileName.startsWith('0') && fileName.length < 6) {
            final nameOnly = fileName.split('.').first;
            if (int.tryParse(nameOnly) != null && nameOnly.length == 1) {
              final newFileName = '0$fileName';
              parts[parts.length - 1] = newFileName;
              fixedUrl = parts.join('/');
              debugPrint("Fixed Audio URL: $fixedUrl");
            }
          }
        }
        
        await _audioPlayer.play(UrlSource(fixedUrl));
        setState(() => _audioError = false);
      }
    } catch (e) {
      debugPrint("Audio Error: $e");
      if (mounted) {
        setState(() => _audioError = true);
      }
    }
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Widget _buildAudioPlayer(String? audioUrl) {
    final notoSansKr = GoogleFonts.notoSansKr();
    final isNT = _isNewTestament(_currentBook);
    
    // 신약이 아니거나, 신약인데 오디오 URL이 없는 경우 "준비 중" 표시
    if (!isNT || audioUrl == null || audioUrl.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.hourglass_empty, color: Colors.grey.shade600, size: 20),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                '구약 오디오는 추후 업데이트 예정입니다.',
                style: notoSansKr.copyWith(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    _currentAudioUrl = audioUrl;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(
                  _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                  color: AppTheme.primaryColor,
                  size: 40,
                ),
                onPressed: _toggleAudio,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '▶ $_currentBook $_currentChapter장 듣기',
                      style: notoSansKr.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (_audioError)
                      Text(
                        '오디오를 불러올 수 없습니다.',
                        style: notoSansKr.copyWith(color: Colors.red, fontSize: 12),
                      )
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(_position),
                            style: notoSansKr.copyWith(
                              color: AppTheme.primaryColor,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            _formatDuration(_duration),
                            style: notoSansKr.copyWith(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              activeTrackColor: AppTheme.primaryColor,
              inactiveTrackColor: AppTheme.primaryColor.withValues(alpha: 0.2),
              thumbColor: AppTheme.primaryColor,
            ),
            child: Slider(
              value: _position.inSeconds.toDouble(),
              max: _duration.inSeconds.toDouble() > 0 ? _duration.inSeconds.toDouble() : 1.0,
              onChanged: (value) async {
                final newPosition = Duration(seconds: value.toInt());
                await _audioPlayer.seek(newPosition);
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notoSansKr = GoogleFonts.notoSansKr();
    final maxChapters = _getMaxChapters(_currentBook);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          '오늘의 성경',
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
      body: Consumer<BibleProvider>(
        builder: (context, bibleProvider, child) {
          return Column(
            children: [
              // 드롭다운 선택 영역
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _currentBook,
                            isExpanded: true,
                            icon: const Icon(Icons.arrow_drop_down, color: AppTheme.primaryColor),
                            items: _allBooks.map((book) {
                              return DropdownMenuItem<String>(
                                value: book['name'] as String,
                                child: Text(
                                  book['name'] as String,
                                  style: notoSansKr.copyWith(
                                    fontSize: 16,
                                    fontWeight: _currentBook == book['name'] ? FontWeight.bold : FontWeight.normal,
                                    color: _currentBook == book['name'] ? AppTheme.primaryColor : AppTheme.textColor,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null && newValue != _currentBook) {
                                setState(() {
                                  _currentBook = newValue;
                                  _currentChapter = 1; // 책이 바뀌면 1장으로 리셋
                                });
                                _loadCurrentChapter();
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 4,
                      child: Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: _currentChapter,
                            isExpanded: true,
                            icon: const Icon(Icons.arrow_drop_down, color: AppTheme.primaryColor),
                            items: List.generate(maxChapters, (index) {
                              final chapter = index + 1;
                              return DropdownMenuItem<int>(
                                value: chapter,
                                child: Text(
                                  '$chapter장',
                                  style: notoSansKr.copyWith(
                                    fontSize: 16,
                                    fontWeight: _currentChapter == chapter ? FontWeight.bold : FontWeight.normal,
                                    color: _currentChapter == chapter ? AppTheme.primaryColor : AppTheme.textColor,
                                  ),
                                ),
                              );
                            }),
                            onChanged: (int? newValue) {
                              if (newValue != null && newValue != _currentChapter) {
                                setState(() {
                                  _currentChapter = newValue;
                                });
                                _loadCurrentChapter();
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 로딩/에러 처리
              if (bibleProvider.isLoading && bibleProvider.currentChapter.isEmpty)
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(color: AppTheme.primaryColor),
                  ),
                )
              else if (bibleProvider.errorMessage != null && bibleProvider.currentChapter.isEmpty)
                Expanded(
                  child: Center(
                    child: Text(
                      bibleProvider.errorMessage!,
                      style: notoSansKr.copyWith(color: Colors.red),
                    ),
                  ),
                )
              else if (bibleProvider.currentChapter.isEmpty)
                Expanded(
                  child: Center(
                    child: Text(
                      '성경 말씀이 없습니다.',
                      style: notoSansKr.copyWith(color: AppTheme.textColor),
                    ),
                  ),
                )
              else
                ...[
                  // 본문 렌더링
                  builderContent(bibleProvider.currentChapter, notoSansKr),
                ]
            ],
          );
        },
      ),
    );
  }

  Widget builderContent(List<BibleVerse> verses, TextStyle notoSansKr) {
    // 첫 번째 구절에서 오디오 URL 가져오기
    final audioUrl = verses.first.audioUrl;

    return Expanded(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 24, right: 24, top: 12),
            child: _buildAudioPlayer(audioUrl),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
              itemCount: verses.length,
              itemBuilder: (context, index) {
                    final verse = verses[index];
                    final isFirstSubtitle = index == 0 && verse.subtitleTitle != null;
                    final isNewSubtitle = index > 0 && 
                                          verse.subtitleTitle != null && 
                                          verse.subtitleTitle != verses[index - 1].subtitleTitle;
      
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isFirstSubtitle || isNewSubtitle)
                          Padding(
                            padding: const EdgeInsets.only(top: 20, bottom: 12),
                            child: Text(
                              verse.subtitleTitle!,
                              style: notoSansKr.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 24,
                                child: Text(
                                  '${verse.verseNumber}',
                                  style: notoSansKr.copyWith(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor.withValues(alpha: 0.6),
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  verse.verseText,
                                  style: notoSansKr.copyWith(
                                    fontSize: 16,
                                    height: 1.6,
                                    color: AppTheme.textColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
    );
  }
}
