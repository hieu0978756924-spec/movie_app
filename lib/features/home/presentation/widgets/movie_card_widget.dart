import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/image_url_helper.dart';
import '../../../../core/utils/user_session.dart';
import '../../controllers/home_controller.dart';
import '../../models/movie.dart';

class MovieCardWidget extends StatefulWidget {
  final Movie movie;

  const MovieCardWidget({
    super.key,
    required this.movie,
  });

  @override
  State<MovieCardWidget> createState() => _MovieCardWidgetState();
}

class _MovieCardWidgetState extends State<MovieCardWidget> {
  void _toggleFavorite() {
    UserSession.instance.requireAuth(
      context,
      actionName: 'thêm phim vào danh sách yêu thích',
      onAuthenticated: () {
        setState(() {
          HomeController.instance.doiTrangThaiYeuThich(widget.movie);
        });

        final isFav = widget.movie.yeuThich;
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 2),
            backgroundColor: AppColors.darkSurface,
            content: Row(
              children: [
                Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? AppColors.primaryRed : Colors.white70,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isFav
                        ? 'Đã thêm "${widget.movie.tenPhim}" vào danh sách yêu thích'
                        : 'Đã xóa "${widget.movie.tenPhim}" khỏi danh sách yêu thích',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final posterUrl = ImageUrlHelper.getPosterUrl(widget.movie.hinhAnh);

    return GestureDetector(
      onTap: () {
        context.push(
          RoutePath.movieDetailPath(widget.movie.id.toString()),
          extra: widget.movie,
        );
      },
      child: Container(
        width: 130,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    posterUrl != null && posterUrl.startsWith('http')
                        ? Image.network(
                            posterUrl,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildFallback(),
                          )
                        : Image.asset(
                            widget.movie.hinhAnh.startsWith('assets/')
                                ? widget.movie.hinhAnh
                                : ImageUrlHelper.getLocalFallbackImage(widget.movie.id),
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildFallback(),
                          ),

                    // Heart Favorite Button
                    Positioned(
                      top: 6,
                      left: 6,
                      child: ListenableBuilder(
                        listenable: HomeController.instance,
                        builder: (context, _) {
                          final isFav = HomeController.instance.favoriteMovieIds.contains(widget.movie.id) || widget.movie.yeuThich;
                          return GestureDetector(
                            onTap: _toggleFavorite,
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isFav ? Icons.favorite : Icons.favorite_border,
                                color: isFav ? AppColors.primaryRed : Colors.white,
                                size: 16,
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Rating Badge
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              color: AppColors.accentGold,
                              size: 12,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${widget.movie.diemDanhGia.toStringAsFixed(1)}/10',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.movie.tenPhim,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallback() {
    return Image.asset(
      ImageUrlHelper.getLocalFallbackImage(widget.movie.id),
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: AppColors.darkSurfaceVariant,
        child: const Center(
          child: Icon(
            Icons.movie_outlined,
            color: Colors.white38,
            size: 32,
          ),
        ),
      ),
    );
  }
}
