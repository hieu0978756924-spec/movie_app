import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../../core/theme/app_colors.dart';

class TrailerPlayerDialog extends StatefulWidget {
  final String youtubeKey;
  final String title;

  const TrailerPlayerDialog({
    super.key,
    required this.youtubeKey,
    required this.title,
  });

  static void show(
    BuildContext context, {
    required String youtubeKey,
    required String title,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => TrailerPlayerDialog(
        youtubeKey: youtubeKey,
        title: title,
      ),
    );
  }

  @override
  State<TrailerPlayerDialog> createState() => _TrailerPlayerDialogState();
}

class _TrailerPlayerDialogState extends State<TrailerPlayerDialog> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.youtubeKey,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.darkSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Trailer: ${widget.title}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.white70),
                ),
              ],
            ),
          ),
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(16)),
            child: YoutubePlayer(
              controller: _controller,
              showVideoProgressIndicator: true,
              progressIndicatorColor: AppColors.primaryRed,
              progressColors: const ProgressBarColors(
                playedColor: AppColors.primaryRed,
                handleColor: AppColors.primaryRed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
