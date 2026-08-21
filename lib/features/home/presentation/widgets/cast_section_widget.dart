import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/image_url_helper.dart';
import '../../domain/entities/cast.dart';

class CastSectionWidget extends StatelessWidget {
  final List<Cast> castList;
  final String? directorName;

  const CastSectionWidget({
    super.key,
    required this.castList,
    this.directorName,
  });

  @override
  Widget build(BuildContext context) {
    if (castList.isEmpty && (directorName == null || directorName!.isEmpty)) {
      return const SizedBox.shrink();
    }

    final topCast = castList.take(10).toList();
    final directorAvatar = ImageUrlHelper.getDirectorAvatar(directorName);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (directorName != null && directorName!.isNotEmpty) ...[
          const Text(
            'Tác giả & Đạo diễn',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.darkSurfaceVariant,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primaryRed.withAlpha(40),
                  backgroundImage: directorAvatar != null &&
                          directorAvatar.startsWith('http')
                      ? NetworkImage(directorAvatar)
                      : null,
                  child: directorAvatar == null ||
                          !directorAvatar.startsWith('http')
                      ? const Icon(
                          Icons.video_camera_front_rounded,
                          color: AppColors.primaryRed,
                          size: 28,
                        )
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        directorName!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Đạo diễn chính / Tác giả',
                        style: TextStyle(
                          color: AppColors.primaryRed,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
        if (topCast.isNotEmpty) ...[
          const Text(
            'Diễn viên chính',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: topCast.length,
              itemBuilder: (context, index) {
                final actor = topCast[index];
                final profilePath = actor.profilePath ?? '';
                final isAsset = profilePath.startsWith('assets/');
                final avatarUrl = ImageUrlHelper.getProfileUrl(profilePath);

                ImageProvider? imageProvider;
                if (isAsset) {
                  imageProvider = AssetImage(profilePath);
                } else if (avatarUrl != null && avatarUrl.startsWith('http')) {
                  imageProvider = NetworkImage(avatarUrl);
                }

                return Container(
                  width: 90,
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: AppColors.darkSurfaceVariant,
                        backgroundImage: imageProvider,
                        child: imageProvider == null
                            ? const Icon(
                                Icons.person,
                                color: Colors.white54,
                                size: 30,
                              )
                            : null,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        actor.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        actor.character,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
      ],
    );
  }
}
