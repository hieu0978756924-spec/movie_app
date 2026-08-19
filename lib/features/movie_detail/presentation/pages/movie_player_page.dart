import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/youtube_utils.dart';
import '../../../home/domain/usecases/get_movie_trailers_usecase.dart';
import '../../../home/models/movie.dart';
import '../../../home/presentation/widgets/pip_trailer_manager.dart';
import '../../../profile/data/watch_history_manager.dart';

class MoviePlayerPage extends StatefulWidget {
  final Movie movie;
  final String? youtubeKey;

  const MoviePlayerPage({
    super.key,
    required this.movie,
    this.youtubeKey,
  });

  @override
  State<MoviePlayerPage> createState() => _MoviePlayerPageState();
}

class _MoviePlayerPageState extends State<MoviePlayerPage> {
  late YoutubePlayerController _controller;
  late String _currentKey;

  // Video rotation angle state: 0 = 0 deg, 1 = 90 deg, 2 = 180 deg, 3 = 270 deg
  int _quarterTurns = 0;
  double _playbackSpeed = 1.0;
  String? _feedbackMessage;
  bool _isManualFullScreen = false;

  final List<double> _availableSpeeds = const [
    0.25,
    0.5,
    0.75,
    1.0,
    1.25,
    1.5,
    1.75,
    2.0
  ];

  @override
  void initState() {
    super.initState();
    PipTrailerManager.instance.closePip();
    WatchHistoryManager.instance.addWatchedVideo(widget.movie);

    String initialKey = widget.youtubeKey ?? '';
    if (initialKey.isEmpty) {
      initialKey = YoutubeUtils.extractYoutubeKey(widget.movie.videoUrl);
    }
    if (initialKey.isEmpty) {
      initialKey = YoutubeUtils.extractYoutubeKey(widget.movie.trailerUrl);
    }
    if (initialKey.isEmpty) {
      initialKey = 'oA-BhGNK7qw';
    }
    _currentKey = initialKey;

    _controller = YoutubePlayerController(
      initialVideoId: _currentKey,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: true,
      ),
    )..addListener(() {
        if (mounted) setState(() {});
      });

    if (widget.youtubeKey == null || widget.youtubeKey!.isEmpty) {
      _fetchTrailerFromApi();
    }
  }

  Future<void> _fetchTrailerFromApi() async {
    try {
      final getMovieTrailers = getIt<GetMovieTrailersUseCase>();
      final result = await getMovieTrailers(widget.movie.id);
      result.fold((_) {}, (trailers) {
        if (trailers.isNotEmpty && mounted) {
          final official = trailers.firstWhere(
            (v) =>
                v.site.toLowerCase() == 'youtube' &&
                v.type.toLowerCase() == 'trailer' &&
                (v.official == true || v.name.toLowerCase().contains('official')),
            orElse: () => trailers.firstWhere(
              (v) =>
                  v.site.toLowerCase() == 'youtube' &&
                  (v.type.toLowerCase() == 'trailer' || v.type.toLowerCase() == 'teaser'),
              orElse: () => trailers.firstWhere(
                (v) => v.site.toLowerCase() == 'youtube',
                orElse: () => trailers.first,
              ),
            ),
          );
          final apiKey = YoutubeUtils.extractYoutubeKey(official.key);
          if (apiKey.isNotEmpty && apiKey != _currentKey) {
            _currentKey = apiKey;
            _controller.load(apiKey);
            if (mounted) setState(() {});
          }
        }
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    // Reset orientation & system UI overlay on dispose
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _controller.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    if (duration.inSeconds <= 0) return '00:00';
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  void _showFeedback(String message) {
    setState(() {
      _feedbackMessage = message;
    });
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          if (_feedbackMessage == message) {
            _feedbackMessage = null;
          }
        });
      }
    });
  }

  void _seekRelative(int seconds) {
    final currentPos = _controller.value.position;
    final duration = _controller.value.metaData.duration;
    final targetPos = currentPos + Duration(seconds: seconds);
    final clampedPos = targetPos < Duration.zero
        ? Duration.zero
        : (duration > Duration.zero && targetPos > duration
            ? duration
            : targetPos);

    _controller.seekTo(clampedPos);
    _showFeedback(seconds > 0 ? 'Tua tới +${seconds}s' : 'Tua lùi ${seconds}s');
  }

  void _setSpeed(double speed) {
    setState(() {
      _playbackSpeed = speed;
    });
    _controller.setPlaybackRate(speed);
    _showFeedback('Tốc độ phát: ${speed}x');
  }

  void _rotateLeft() {
    setState(() {
      _quarterTurns = (_quarterTurns - 1) % 4;
      if (_quarterTurns < 0) _quarterTurns += 4;
    });

    if (_quarterTurns == 1 || _quarterTurns == 3) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
    } else {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
    _showFeedback('Xoay trái (${_quarterTurns * 90}°)');
  }

  void _rotateRight() {
    setState(() {
      _quarterTurns = (_quarterTurns + 1) % 4;
    });

    if (_quarterTurns == 1 || _quarterTurns == 3) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeRight]);
    } else {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
    _showFeedback('Xoay phải (${_quarterTurns * 90}°)');
  }

  void _resetRotation() {
    setState(() {
      _quarterTurns = 0;
    });
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _showFeedback('Khôi phục góc xoay mặc định');
  }

  void _toggleFullScreen() {
    setState(() {
      _isManualFullScreen = !_isManualFullScreen;
    });
    _controller.toggleFullScreenMode();
    if (_isManualFullScreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      _showFeedback('Đã bật toàn màn hình');
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      _showFeedback('Đã thoát toàn màn hình');
    }
  }

  void _exitPlayer() {
    if (_isManualFullScreen) {
      _toggleFullScreen();
    }
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  void _switchToPipMode() {
    final currentKey = _currentKey;
    final movieTitle = widget.movie.tenPhim;
    final movie = widget.movie;

    context.pop(); // Close current page
    PipTrailerManager.instance.playInPip(
      context,
      youtubeKey: currentKey,
      title: movieTitle,
      movie: movie,
    );
  }

  @override
  Widget build(BuildContext context) {
    final posMs = _controller.value.position.inMilliseconds.toDouble();
    final durMs = _controller.value.metaData.duration.inMilliseconds.toDouble();
    final maxMs = durMs > 0 ? durMs : 1.0;
    final currentVal = posMs.clamp(0.0, maxMs);

    return YoutubePlayerBuilder(
      onEnterFullScreen: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      },
      onExitFullScreen: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      },
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: false,
        onReady: () {
          _controller.unMute();
          _controller.setVolume(100);
        },
      ),
      builder: (context, player) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: _isManualFullScreen
              ? null
              : AppBar(
                  backgroundColor: Colors.black,
                  elevation: 0,
                  title: Text(
                    widget.movie.tenPhim,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => context.pop(),
                  ),
                  actions: [
                    IconButton(
                      tooltip: 'Thu nhỏ PiP',
                      icon: const Icon(
                        Icons.picture_in_picture_alt_rounded,
                        color: AppColors.primaryRed,
                      ),
                      onPressed: _switchToPipMode,
                    ),
                    IconButton(
                      tooltip: _isManualFullScreen
                          ? 'Thoát toàn màn hình'
                          : 'Xem toàn màn hình',
                      icon: Icon(
                        _isManualFullScreen
                            ? Icons.fullscreen_exit
                            : Icons.fullscreen,
                        color: Colors.white,
                      ),
                      onPressed: _toggleFullScreen,
                    ),
                  ],
                ),
          body: SafeArea(
            child: Column(
              children: [
                // Main Player Area with Rotation Transform & Visual Feedback
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Center(
                        child: _currentKey.isEmpty
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.videocam_off_outlined,
                                    size: 64,
                                    color: Colors.white38,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Trailer cho phim "${widget.movie.tenPhim}" chưa có sẵn.',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 15,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              )
                            : RotatedBox(
                                quarterTurns: _quarterTurns,
                                child: player,
                              ),
                      ),
                      // Feedback Toast Overlay
                      if (_feedbackMessage != null)
                        Positioned(
                          top: 20,
                          child: AnimatedOpacity(
                            opacity: _feedbackMessage != null ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 200),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withAlpha(200),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.primaryRed,
                                  width: 1,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black45,
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.info_outline_rounded,
                                    color: AppColors.primaryRed,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _feedbackMessage!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                      // Floating Top-Left Back / Exit Button
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            tooltip: 'Thoát',
                            icon: const Icon(
                              Icons.arrow_back_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                            onPressed: _exitPlayer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Youtube-Style Bottom Player Controls Panel (Matching Screenshot)
                Container(
                  color: const Color(0xFF0F0F12),
                  padding: const EdgeInsets.only(bottom: 6, top: 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 1. Timeline Progress Bar
                      SliderTheme(
                        data: const SliderThemeData(
                          trackHeight: 3.0,
                          thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6.0),
                          overlayShape: RoundSliderOverlayShape(overlayRadius: 12.0),
                          activeTrackColor: AppColors.primaryRed,
                          inactiveTrackColor: Colors.white24,
                          thumbColor: AppColors.primaryRed,
                        ),
                        child: Slider(
                          value: currentVal,
                          min: 0.0,
                          max: maxMs,
                          onChanged: (val) {
                            _controller.seekTo(Duration(milliseconds: val.toInt()));
                          },
                        ),
                      ),

                      // 2. Toolbar Row: Play, Volume, Timestamp, Seek -10/+10, Speed Badge, Settings Gear ⚙️, Fullscreen
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Play / Pause Button
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                tooltip: _controller.value.isPlaying ? 'Tạm dừng' : 'Phát',
                                icon: Icon(
                                  _controller.value.isPlaying
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                onPressed: () {
                                  if (_controller.value.isPlaying) {
                                    _controller.pause();
                                  } else {
                                    _controller.play();
                                  }
                                },
                              ),
                              const SizedBox(width: 8),

                              // Mute / Unmute Button
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                tooltip: _controller.value.volume == 0 ? 'Bật âm thanh' : 'Tắt âm thanh',
                                icon: Icon(
                                  _controller.value.volume == 0
                                      ? Icons.volume_off_rounded
                                      : Icons.volume_up_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                onPressed: () {
                                  if (_controller.value.volume == 0) {
                                    _controller.unMute();
                                    _controller.setVolume(100);
                                  } else {
                                    _controller.mute();
                                  }
                                },
                              ),
                              const SizedBox(width: 8),

                              // Timestamp: 0:43 / 1:23:22
                              Text(
                                '${_formatDuration(_controller.value.position)} / ${_formatDuration(_controller.value.metaData.duration)}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Tua lùi -10s
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                tooltip: 'Tua lùi 10s',
                                icon: const Icon(
                                  Icons.replay_10_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                onPressed: () => _seekRelative(-10),
                              ),
                              const SizedBox(width: 8),

                              // Tua tới +10s
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                tooltip: 'Tua tới 10s',
                                icon: const Icon(
                                  Icons.forward_10_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                onPressed: () => _seekRelative(10),
                              ),
                              const SizedBox(width: 8),

                              // Speed Badge (e.g. x1.25, x1.5, x2)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryRed.withAlpha(40),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppColors.primaryRed, width: 0.8),
                                ),
                                child: Text(
                                  '${_playbackSpeed}x',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),

                              // Settings Gear Icon ⚙️ (Speed Menu & Rotation)
                              PopupMenuButton<dynamic>(
                                tooltip: 'Cài đặt (Tốc độ phát & Xoay)',
                                color: const Color(0xFF24242A),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                icon: const Icon(
                                  Icons.settings_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                onSelected: (value) {
                                  if (value == 'exit') {
                                    _exitPlayer();
                                  } else if (value is double) {
                                    _setSpeed(value);
                                  } else if (value == 'rotate_left') {
                                    _rotateLeft();
                                  } else if (value == 'rotate_right') {
                                    _rotateRight();
                                  } else if (value == 'reset_rotate') {
                                    _resetRotation();
                                  }
                                },
                                itemBuilder: (ctx) => [
                                  const PopupMenuItem<dynamic>(
                                    enabled: false,
                                    child: Text(
                                      '⚡ TỐC ĐỘ PHÁT VIDEO',
                                      style: TextStyle(
                                        color: Colors.amber,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  ..._availableSpeeds.map((s) => PopupMenuItem<dynamic>(
                                        value: s,
                                        child: Row(
                                          children: [
                                            Icon(
                                              s == _playbackSpeed
                                                  ? Icons.check_circle
                                                  : Icons.circle_outlined,
                                              color: s == _playbackSpeed
                                                  ? AppColors.primaryRed
                                                  : Colors.white38,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              s == 1.0 ? '1.0x (Chuẩn)' : '${s}x',
                                              style: TextStyle(
                                                color: s == _playbackSpeed
                                                    ? AppColors.primaryRed
                                                    : Colors.white,
                                                fontWeight: s == _playbackSpeed
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )),
                                  const PopupMenuDivider(),
                                  const PopupMenuItem<dynamic>(
                                    enabled: false,
                                    child: Text(
                                      '🔄 GÓC XOAY MÀN HÌNH',
                                      style: TextStyle(
                                        color: Colors.cyanAccent,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const PopupMenuItem<dynamic>(
                                    value: 'rotate_left',
                                    child: Row(
                                      children: [
                                        Icon(Icons.rotate_left_rounded, color: Colors.cyanAccent, size: 18),
                                        SizedBox(width: 8),
                                        Text('Xoay Trái 90°', style: TextStyle(color: Colors.white)),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem<dynamic>(
                                    value: 'rotate_right',
                                    child: Row(
                                      children: [
                                        Icon(Icons.rotate_right_rounded, color: Colors.cyanAccent, size: 18),
                                        SizedBox(width: 8),
                                        Text('Xoay Phải 90°', style: TextStyle(color: Colors.white)),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem<dynamic>(
                                    value: 'reset_rotate',
                                    child: Row(
                                      children: [
                                        Icon(Icons.screen_rotation_rounded, color: Colors.amber, size: 18),
                                        SizedBox(width: 8),
                                        Text('Đặt lại góc xoay', style: TextStyle(color: Colors.white)),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuDivider(),
                                  const PopupMenuItem<dynamic>(
                                    value: 'exit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.exit_to_app_rounded, color: AppColors.primaryRed, size: 18),
                                        SizedBox(width: 8),
                                        Text(
                                          'Thoát trình phát',
                                          style: TextStyle(
                                            color: AppColors.primaryRed,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 2),

                              // Fullscreen Button ⛶
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                tooltip: _isManualFullScreen ? 'Thoát toàn màn hình' : 'Toàn màn hình',
                                icon: Icon(
                                  _isManualFullScreen
                                      ? Icons.fullscreen_exit_rounded
                                      : Icons.fullscreen_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                onPressed: _toggleFullScreen,
                              ),
                              const SizedBox(width: 6),

                              // Exit Player Button 🚪 (Thoát)
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                tooltip: 'Thoát',
                                icon: const Icon(
                                  Icons.exit_to_app_rounded,
                                  color: AppColors.primaryRed,
                                  size: 22,
                                ),
                                onPressed: _exitPlayer,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

