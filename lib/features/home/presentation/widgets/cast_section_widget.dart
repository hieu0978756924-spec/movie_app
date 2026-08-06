import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/image_url_helper.dart';
import '../../domain/entities/cast.dart';

class CastSectionWidget extends StatelessWidget {
  final List<Cast> castList;

  const CastSectionWidget({
    super.key,
    required this.castList,
  });

  @override
  Widget build(BuildContext context) {
    if (castList.isEmpty) return const SizedBox.shrink();

    final topCast = castList.take(10).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              final avatarUrl = ImageUrlHelper.getProfileUrl(actor.profilePath);

              return Container(
                width: 90,
                margin: const EdgeInsets.only(right: 12),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.darkSurfaceVariant,
                      backgroundImage: avatarUrl != null &&
                              avatarUrl.startsWith('http')
                          ? NetworkImage(avatarUrl)
                          : null,
                      child: avatarUrl == null || !avatarUrl.startsWith('http')
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
    );
  }
}
