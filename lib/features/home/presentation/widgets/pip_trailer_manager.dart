import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/youtube_utils.dart';
import 'package:movie_app/features/profile/data/watch_history_manager.dart';
import 'package:movie_app/features/home/models/movie.dart';
import 'package:movie_app/features/home/domain/usecases/get_movie_trailers_usecase.dart';

class PipTrailerManager {
  PipTrailerManager._();
  static final PipTrailerManager instance = PipTrailerManager._();

  OverlayEntry? _overlayEntry;
  YoutubePlayerController? _controller;
  String? _youtubeKey;
  String? _title;
  bool _isPip = false;
  bool _isVerticalDock = false;
  bool _isLeftDock = false; // false: Right side, true: Left side
  Offset _position = const Offset(16, 500);

  bool get isPlaying => _controller != null;
  bool get isPip => _isPip;
  bool get isVerticalDock => _isVerticalDock;
  String? get currentTitle => _title;

  void playTrailer(
    BuildContext context, {
    required String youtubeKey,
    required String title,
    Movie? movie,
    bool startInPip = false,
  }) {
    String keyToPlay = YoutubeUtils.extractYoutubeKey(youtubeKey);
    if (keyToPlay.isEmpty && movie != null) {
      keyToPlay = YoutubeUtils.getFallbackTrailerKeyForMovieId(movie.id);
    }

    if (keyToPlay.isEmpty && movie != null) {
      getIt<GetMovieTrailersUseCase>()(movie.id).then((result) {
        result.fold((_) {}, (trailers) {
          if (trailers.isNotEmpty) {
            final official = trailers.firstWhere(
              (v) =>
                  v.site.toLowerCase() == 'youtube' &&
                  (v.type.toLowerCase() == 'trailer' || v.official),
              orElse: () => trailers.first,
            );
            final apiKey = YoutubeUtils.extractYoutubeKey(official.key);
            if (apiKey.isNotEmpty && context.mounted) {
              playTrailer(
                context,
                youtubeKey: apiKey,
                title: title,
                movie: movie,
                startInPip: startInPip,
              );
            }
          }
        });
      });
      return;
    }

    if (keyToPlay.isEmpty) {
      final movieTitle = movie?.tenPhim ?? title;
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Trailer cho phim "$movieTitle" chưa có sẵn.'),
            backgroundColor: AppColors.primaryRed,
          ),
        );
      }
      return;
    }

    if (_youtubeKey != keyToPlay || _controller == null) {
      closePip();
      _youtubeKey = keyToPlay;
      _title = title;
      _controller = YoutubePlayerController(
        initialVideoId: keyToPlay,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
          enableCaption: true,
        ),
      );
    }

    if (startInPip) {
      switchToPip(context);
    } else {
      _showDialogMode(context);
    }
  }

  void playInPip(
    BuildContext context, {
    required String youtubeKey,
    required String title,
    Movie? movie,
  }) {
    playTrailer(
      context,
      youtubeKey: youtubeKey,
      title: title,
      movie: movie,
      startInPip: true,
    );
  }

  void _showDialogMode(BuildContext context) {
    _removeOverlay();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        final mediaQuery = MediaQuery.of(dialogContext);
        final maxHeight = mediaQuery.size.height * 0.9;
        final maxWidth = mediaQuery.size.width * 0.95;

        int quarterTurns = 0;
        double playbackSpeed = 1.0;

        return StatefulBuilder(
          builder: (dContext, setDialogState) {
            return Dialog(
              backgroundColor: AppColors.darkSurface,
              insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: maxHeight,
                  maxWidth: maxWidth > 550 ? 550 : maxWidth,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Đang phát: ${_title ?? ""}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // Button Switch to Vertical Dock Mode
                            IconButton(
                              tooltip: 'Chuyển Thanh Dọc (Trái/Phải)',
                              icon: const Icon(Icons.view_sidebar_rounded,
                                  color: Colors.amber, size: 20),
                              onPressed: () {
                                Navigator.of(dialogContext).pop();
                                switchToVerticalDock(context);
                              },
                            ),
                            // Button PiP Mode
                            IconButton(
                              tooltip: 'Thu nhỏ PiP (1/10 màn hình)',
                              icon: const Icon(Icons.picture_in_picture_alt_rounded,
                                  color: AppColors.primaryRed, size: 20),
                              onPressed: () {
                                Navigator.of(dialogContext).pop();
                                switchToPip(context);
                              },
                            ),
                            // Button Close
                            IconButton(
                              tooltip: 'Đóng',
                              icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                              onPressed: () {
                                Navigator.of(dialogContext).pop();
                                closePip();
                              },
                            ),
                          ],
                        ),
                      ),
                      // Youtube Player Body with Rotation Support
                      if (_controller != null)
                        ClipRRect(
                          child: RotatedBox(
                            quarterTurns: quarterTurns,
                            child: YoutubePlayer(
                              controller: _controller!,
                              showVideoProgressIndicator: true,
                              progressIndicatorColor: AppColors.primaryRed,
                              progressColors: const ProgressBarColors(
                                playedColor: AppColors.primaryRed,
                                handleColor: AppColors.primaryRed,
                              ),
                              onReady: () {
                                _controller?.unMute();
                                _controller?.setVolume(100);
                              },
                            ),
                          ),
                        ),

                      // Player Control Toolbar: Fast Seek, Speed, Rotation, Fullscreen
                      Container(
                        padding: const EdgeInsets.only(bottom: 6, top: 0, left: 6, right: 6),
                        decoration: const BoxDecoration(
                          color: Color(0xFF0F0F12),
                          borderRadius:
                              BorderRadius.vertical(bottom: Radius.circular(16)),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 1. Timeline Progress Bar
                            if (_controller != null)
                              Builder(builder: (ctx) {
                                final posMs = _controller!.value.position.inMilliseconds.toDouble();
                                final durMs = _controller!.value.metaData.duration.inMilliseconds.toDouble();
                                final maxMs = durMs > 0 ? durMs : 1.0;
                                final currentVal = posMs.clamp(0.0, maxMs);

                                return SliderTheme(
                                  data: const SliderThemeData(
                                    trackHeight: 3.0,
                                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 5.0),
                                    overlayShape: RoundSliderOverlayShape(overlayRadius: 10.0),
                                    activeTrackColor: AppColors.primaryRed,
                                    inactiveTrackColor: Colors.white24,
                                    thumbColor: AppColors.primaryRed,
                                  ),
                                  child: Slider(
                                    value: currentVal,
                                    min: 0.0,
                                    max: maxMs,
                                    onChanged: (val) {
                                      _controller?.seekTo(Duration(milliseconds: val.toInt()));
                                    },
                                  ),
                                );
                              }),

                            // 2. Toolbar Row (Play, Mute, Time 0:43/1:23:22, Seek -10/+10, Speed Badge, Gear ⚙️, Fullscreen)
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Play / Pause Button
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    tooltip: (_controller?.value.isPlaying ?? false) ? 'Tạm dừng' : 'Phát',
                                    icon: Icon(
                                      (_controller?.value.isPlaying ?? false)
                                          ? Icons.pause_rounded
                                          : Icons.play_arrow_rounded,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                    onPressed: () {
                                      if (_controller?.value.isPlaying ?? false) {
                                        _controller?.pause();
                                      } else {
                                        _controller?.play();
                                      }
                                    },
                                  ),
                                  const SizedBox(width: 6),

                                  // Mute / Unmute Button
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    tooltip: ((_controller?.value.volume ?? 100) == 0) ? 'Bật âm' : 'Tắt âm',
                                    icon: Icon(
                                      ((_controller?.value.volume ?? 100) == 0)
                                          ? Icons.volume_off_rounded
                                          : Icons.volume_up_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      if ((_controller?.value.volume ?? 100) == 0) {
                                        _controller?.unMute();
                                        _controller?.setVolume(100);
                                      } else {
                                        _controller?.mute();
                                      }
                                    },
                                  ),
                                  const SizedBox(width: 6),

                                  // Timestamp: 0:43 / 1:23:22
                                  Builder(builder: (ctx) {
                                    String fmt(Duration d) {
                                      if (d.inSeconds <= 0) return '00:00';
                                      final h = d.inHours;
                                      final m = d.inMinutes.remainder(60);
                                      final s = d.inSeconds.remainder(60);
                                      return h > 0
                                          ? '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}'
                                          : '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
                                    }

                                    final p = _controller?.value.position ?? Duration.zero;
                                    final d = _controller?.value.metaData.duration ?? Duration.zero;
                                    return Text(
                                      '${fmt(p)} / ${fmt(d)}',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 10,
                                        fontFamily: 'monospace',
                                      ),
                                    );
                                  }),

                                  const SizedBox(width: 8),

                                  // Tua lùi -10s
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    tooltip: 'Tua lùi 10s',
                                    icon: const Icon(Icons.replay_10_rounded, color: Colors.white, size: 20),
                                    onPressed: () {
                                      final currentPos = _controller?.value.position ?? Duration.zero;
                                      final target = currentPos - const Duration(seconds: 10);
                                      _controller?.seekTo(target < Duration.zero ? Duration.zero : target);
                                    },
                                  ),
                                  const SizedBox(width: 6),

                                  // Tua tới +10s
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    tooltip: 'Tua tới 10s',
                                    icon: const Icon(Icons.forward_10_rounded, color: Colors.white, size: 20),
                                    onPressed: () {
                                      final currentPos = _controller?.value.position ?? Duration.zero;
                                      final duration = _controller?.value.metaData.duration ?? Duration.zero;
                                      final target = currentPos + const Duration(seconds: 10);
                                      _controller?.seekTo(duration > Duration.zero && target > duration ? duration : target);
                                    },
                                  ),
                                  const SizedBox(width: 6),

                                  // Speed Badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryRed.withAlpha(40),
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(color: AppColors.primaryRed, width: 0.8),
                                    ),
                                    child: Text(
                                      '${playbackSpeed}x',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),

                                  // Settings Gear Icon ⚙️
                                  PopupMenuButton<dynamic>(
                                    tooltip: 'Cài đặt (Tốc độ & Xoay)',
                                    color: const Color(0xFF24242A),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    icon: const Icon(Icons.settings_rounded, color: Colors.white, size: 20),
                                    onSelected: (value) {
                                      if (value == 'exit') {
                                        Navigator.of(dialogContext).pop();
                                        closePip();
                                      } else if (value is double) {
                                        setDialogState(() {
                                          playbackSpeed = value;
                                        });
                                        _controller?.setPlaybackRate(value);
                                      } else if (value == 'rotate_left') {
                                        setDialogState(() {
                                          quarterTurns = (quarterTurns - 1) % 4;
                                          if (quarterTurns < 0) quarterTurns += 4;
                                        });
                                      } else if (value == 'rotate_right') {
                                        setDialogState(() {
                                          quarterTurns = (quarterTurns + 1) % 4;
                                        });
                                      } else if (value == 'reset_rotate') {
                                        setDialogState(() {
                                          quarterTurns = 0;
                                        });
                                      }
                                    },
                                    itemBuilder: (ctx) => [
                                      const PopupMenuItem<dynamic>(
                                        enabled: false,
                                        child: Text('⚡ TỐC ĐỘ PHÁT', style: TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.bold)),
                                      ),
                                      ...[0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0].map((s) => PopupMenuItem<dynamic>(
                                            value: s,
                                            child: Text(s == 1.0 ? '1.0x (Chuẩn)' : '${s}x', style: TextStyle(color: s == playbackSpeed ? AppColors.primaryRed : Colors.white)),
                                          )),
                                      const PopupMenuDivider(),
                                      const PopupMenuItem<dynamic>(
                                        enabled: false,
                                        child: Text('🔄 XOAY MÀN HÌNH', style: TextStyle(color: Colors.cyanAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                                      ),
                                      const PopupMenuItem<dynamic>(
                                        value: 'rotate_left',
                                        child: Row(children: [Icon(Icons.rotate_left_rounded, color: Colors.cyanAccent, size: 16), SizedBox(width: 6), Text('Xoay Trái 90°', style: TextStyle(color: Colors.white))]),
                                      ),
                                      const PopupMenuItem<dynamic>(
                                        value: 'rotate_right',
                                        child: Row(children: [Icon(Icons.rotate_right_rounded, color: Colors.cyanAccent, size: 16), SizedBox(width: 6), Text('Xoay Phải 90°', style: TextStyle(color: Colors.white))]),
                                      ),
                                      const PopupMenuItem<dynamic>(
                                        value: 'reset_rotate',
                                        child: Row(children: [Icon(Icons.screen_rotation_rounded, color: Colors.amber, size: 16), SizedBox(width: 6), Text('Đặt lại góc xoay', style: TextStyle(color: Colors.white))]),
                                      ),
                                      const PopupMenuDivider(),
                                      const PopupMenuItem<dynamic>(
                                        value: 'exit',
                                        child: Row(children: [Icon(Icons.exit_to_app_rounded, color: AppColors.primaryRed, size: 16), SizedBox(width: 6), Text('Thoát trình phát', style: TextStyle(color: AppColors.primaryRed, fontWeight: FontWeight.bold))]),
                                      ),
                                    ],
                                  ),

                                  // Fullscreen Button ⛶
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    tooltip: 'Xem Toàn Màn Hình',
                                    icon: const Icon(Icons.fullscreen_rounded, color: Colors.white, size: 24),
                                    onPressed: () {
                                      _controller?.toggleFullScreenMode();
                                    },
                                  ),
                                  const SizedBox(width: 4),

                                  // Exit Player Button 🚪 (Thoát)
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    tooltip: 'Thoát trình phát',
                                    icon: const Icon(Icons.exit_to_app_rounded, color: AppColors.primaryRed, size: 22),
                                    onPressed: () {
                                      Navigator.of(dialogContext).pop();
                                      closePip();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void switchToVerticalDock(BuildContext context) {
    if (_controller == null) return;
    _removeOverlay();

    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    const dockWidth = 230.0;
    final dockHeight = (screenHeight * 0.55).clamp(240.0, 360.0);

    double topPos = (screenHeight - dockHeight) / 2;
    if (topPos < 40) topPos = 40;

    _isVerticalDock = true;
    _isPip = false;

    _overlayEntry = OverlayEntry(
      builder: (overlayContext) {
        return StatefulBuilder(
          builder: (stfContext, setState) {
            final double leftPos = _isLeftDock
                ? 12.0
                : (screenWidth - dockWidth - 12.0).clamp(12.0, screenWidth - dockWidth);

            return Positioned(
              left: leftPos,
              top: topPos,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: dockWidth,
                  height: dockHeight,
                  decoration: BoxDecoration(
                    color: AppColors.darkSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primaryRed, width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black87,
                        blurRadius: 16,
                        spreadRadius: 3,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Header with Controls & Left/Right Flip Button
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: const BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
                        ),
                        child: Row(
                          children: [
                            // Left / Right Side Toggle Button
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              tooltip: _isLeftDock
                                  ? 'Chuyển thanh dọc sang bên PHẢI'
                                  : 'Chuyển thanh dọc sang bên TRÁI',
                              icon: Icon(
                                _isLeftDock
                                    ? Icons.arrow_circle_right_outlined
                                    : Icons.arrow_circle_left_outlined,
                                color: Colors.amber,
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isLeftDock = !_isLeftDock;
                                });
                              },
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _title ?? 'Trailer',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // Expand to Dialog Mode
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              tooltip: 'Phóng to Dialog',
                              icon: const Icon(
                                Icons.open_in_full,
                                color: Colors.white70,
                                size: 16,
                              ),
                              onPressed: () {
                                _removeOverlay();
                                _showDialogMode(context);
                              },
                            ),
                            const SizedBox(width: 8),
                            // Close
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              tooltip: 'Đóng',
                              icon: const Icon(
                                Icons.close,
                                color: AppColors.primaryRed,
                                size: 18,
                              ),
                              onPressed: () {
                                closePip();
                              },
                            ),
                          ],
                        ),
                      ),
                      // Video Player Container with Overflow Protection
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(14)),
                          child: SingleChildScrollView(
                            physics: const NeverScrollableScrollPhysics(),
                            child: _controller != null
                                ? YoutubePlayer(
                                    controller: _controller!,
                                    showVideoProgressIndicator: true,
                                    progressIndicatorColor: AppColors.primaryRed,
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ),
                      ),
                      // Indicator bar: Left / Right status
                      Container(
                        width: double.infinity,
                        color: Colors.black54,
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Text(
                          _isLeftDock ? '◄ Thanh dọc Trái' : 'Thanh dọc Phải ►',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.amberAccent,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void switchToPip(BuildContext context) {
    if (_controller == null) return;
    _removeOverlay();

    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    // Size ~ 1/10 screen size: width 190px, height 110px
    const pipWidth = 190.0;
    const pipHeight = 110.0;

    // Default position: bottom right corner
    _position = Offset(
      screenWidth - pipWidth - 16,
      screenHeight - pipHeight - 90,
    );

    _isPip = true;
    _isVerticalDock = false;
    _overlayEntry = OverlayEntry(
      builder: (overlayContext) {
        return StatefulBuilder(
          builder: (stfContext, setState) {
            return Positioned(
              left: _position.dx,
              top: _position.dy,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    double newX = _position.dx + details.delta.dx;
                    double newY = _position.dy + details.delta.dy;

                    // Clamping within screen bounds
                    newX = newX.clamp(8.0, screenWidth - pipWidth - 8.0);
                    newY = newY.clamp(40.0, screenHeight - pipHeight - 40.0);

                    _position = Offset(newX, newY);
                  });
                },
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: pipWidth,
                    height: pipHeight + 28, // video + mini title bar
                    decoration: BoxDecoration(
                      color: AppColors.darkSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primaryRed, width: 1.5),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black54,
                          blurRadius: 10,
                          spreadRadius: 2,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // PiP Title & Control Bar (Close Dock & Expand)
                        Container(
                          height: 28,
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          decoration: const BoxDecoration(
                            color: Colors.black87,
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(10)),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.drag_handle,
                                color: Colors.white54,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  _title ?? 'Trailer',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              // Expand Back to Dialog
                              GestureDetector(
                                onTap: () {
                                  _removeOverlay();
                                  _showDialogMode(context);
                                },
                                child: const Icon(
                                  Icons.open_in_full,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Close Dock (Close PiP)
                              GestureDetector(
                                onTap: () {
                                  closePip();
                                },
                                child: const Icon(
                                  Icons.close,
                                  color: AppColors.primaryRed,
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // PiP Video Player
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(10)),
                            child: SingleChildScrollView(
                              physics: const NeverScrollableScrollPhysics(),
                              child: _controller != null
                                  ? YoutubePlayer(
                                      controller: _controller!,
                                      showVideoProgressIndicator: false,
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isPip = false;
    _isVerticalDock = false;
  }

  void closePip() {
    _removeOverlay();
    _controller?.dispose();
    _controller = null;
    _youtubeKey = null;
    _title = null;
    _isPip = false;
    _isVerticalDock = false;
  }
}
