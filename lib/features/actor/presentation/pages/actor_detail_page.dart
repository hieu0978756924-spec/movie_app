import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/controllers/home_controller.dart';
import '../../models/actor.dart';

class ActorDetailPage extends StatelessWidget {
  final int actorId;

  const ActorDetailPage({
    super.key,
    required this.actorId,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = AppLocalizations.of(context);
    final actor = HomeController.instance.getActorById(actorId) ??
        Actor(
          id: actorId,
          name: 'Diễn viên #$actorId',
          profilePath: 'assets/images/actor_1.jpg',
          biography:
              'Thông tin tiểu sử diễn viên đang được cập nhật từ hệ thống dữ liệu đám mây Góc Phim.',
          birthday: '1995-12-27',
          placeOfBirth: 'Hollywood, USA',
          knownFor: const [
            KnownMovie(
              id: 1,
              title: 'Dune: Part Two',
              posterPath: 'assets/images/dune2.jpg',
            ),
          ],
        );

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(actor.name),
        backgroundColor:
            isDark ? AppColors.darkBackground : AppColors.lightBackground,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Actor Profile Image Card
              Center(
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryRed.withValues(alpha: 0.3),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: actor.profilePath.startsWith('http')
                        ? Image.network(
                            actor.profilePath,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: AppColors.darkSurfaceVariant,
                              child: const Icon(
                                Icons.person,
                                size: 64,
                                color: Colors.white54,
                              ),
                            ),
                          )
                        : Image.asset(
                            actor.profilePath.startsWith('assets/')
                                ? actor.profilePath
                                : 'assets/images/actor_1.jpg',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: AppColors.darkSurfaceVariant,
                              child: const Icon(
                                Icons.person,
                                size: 64,
                                color: Colors.white54,
                              ),
                            ),
                          ),
                  ),

                ),
              ),
              const SizedBox(height: 16),

              Center(
                child: Text(
                  actor.name,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.lightTextPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.cake_outlined,
                    size: 16,
                    color: AppColors.accentGold,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    actor.birthday,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white70 : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: AppColors.primaryRed,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      actor.placeOfBirth,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white70 : AppColors.lightTextSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Biography Section
              Text(
                locale.translate('biography'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurfaceVariant,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? Colors.white10 : Colors.black12,
                  ),
                ),
                child: Text(
                  actor.biography,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: isDark ? Colors.white70 : AppColors.lightTextSecondary,

                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Known For Movies Section
              Text(
                locale.translate('known_for'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: actor.knownFor.length,
                  itemBuilder: (context, index) {
                    final movie = actor.knownFor[index];
                    return GestureDetector(
                      onTap: () {
                        context.push(RoutePath.movieDetailPath(movie.id));
                      },
                      child: Container(
                        width: 110,
                        margin: const EdgeInsets.only(right: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(
                                  movie.posterPath,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                    color: AppColors.darkSurfaceVariant,
                                    child: const Icon(
                                      Icons.movie,
                                      color: Colors.white38,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              movie.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.white
                                    : AppColors.lightTextPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
