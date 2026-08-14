import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../../core/theme/app_colors.dart';

import 'package:movie_app/features/profile/data/watch_history_manager.dart';
import 'package:movie_app/features/home/models/movie.dart';

class PipTrailerManager {
  PipTrailerManager._();
  static final PipTrailerManager instance = PipTrailerManager._();

  OverlayEntry? _overlayEntry;
  YoutubePlayerController? _controller;
  String? _youtubeKey;
  String? _title;
  bool _isPip = false;
  Offset _position = const Offset(16, 500);

  bool get isPlaying => _controller != null;
  bool get isPip => _isPip;
  String? get currentTitle => _title;

  void playTrailer(
    BuildContext context, {
    required String youtubeKey,
    required String title,
    Movie? movie,
  }) {
    if (movie != null) {
      WatchHistoryManager.instance.addWatchedVideo(movie);
    }
    final keyToPlay = youtubeKey.trim().isEmpty ? 'cSR2yoExSxw' : youtubeKey.trim();
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
      )..addListener(() {
          if (_controller != null &&
              _controller!.value.hasError &&
              _youtubeKey != 'cSR2yoExSxw') {
            _youtubeKey = 'cSR2yoExSxw';
            _controller?.load('cSR2yoExSxw');
          }
        });
    }
    _showDialogMode(context);
  }

  void _showDialogMode(BuildContext context) {
    if (_isPip) {
      _removeOverlay();
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: AppColors.darkSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Trailer: ${_title ?? ""}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Button PiP Mode
                    IconButton(
                      tooltip: 'Thu nhỏ PiP (1/10 màn hình)',
                      icon: const Icon(Icons.picture_in_picture_alt_rounded,
                          color: AppColors.primaryRed, size: 22),
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        switchToPip(context);
                      },
                    ),
                    // Button Close
                    IconButton(
                      tooltip: 'Đóng',
                      icon: const Icon(Icons.close, color: Colors.white70, size: 22),
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        closePip();
                      },
                    ),
                  ],
                ),
              ),
              // Youtube Player Body
              if (_controller != null)
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(16)),
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
            ],
          ),
        );
      },
    );
  }

  void switchToPip(BuildContext context) {
    if (_controller == null || _overlayEntry != null) return;

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
                            child: _controller != null
                                ? YoutubePlayer(
                                    controller: _controller!,
                                    showVideoProgressIndicator: false,
                                  )
                                : const SizedBox.shrink(),
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
  }

  void closePip() {
    _removeOverlay();
    _controller?.dispose();
    _controller = null;
    _youtubeKey = null;
    _title = null;
    _isPip = false;
  }
}
