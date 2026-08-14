import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/image_url_helper.dart';
import '../../home/controllers/home_controller.dart';
import '../../home/models/movie.dart';

class FavoritesView extends StatefulWidget {
  const FavoritesView({super.key});

  @override
  State<FavoritesView> createState() => _FavoritesViewState();
}

class _FavoritesViewState extends State<FavoritesView> {
  void _toggleFavorite(Movie movie) {
    setState(() {
      HomeController.instance.doiTrangThaiYeuThich(movie);
    });
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.darkSurface,
        content: Row(
          children: [
            Icon(
              movie.yeuThich ? Icons.favorite : Icons.favorite_border,
              color: movie.yeuThich ? AppColors.primaryRed : Colors.white70,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                movie.yeuThich
                    ? 'Đã thêm "${movie.tenPhim}" vào Phim yêu thích'
                    : 'Đã xóa "${movie.tenPhim}" khỏi Phim yêu thích',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPoster(Movie movie) {
    final posterUrl = ImageUrlHelper.getPosterUrl(movie.hinhAnh);
    if (posterUrl != null && posterUrl.startsWith('http')) {
      return Image.network(
        posterUrl,
        width: 75,
        height: 110,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildFallbackPoster(movie),
      );
    }
    return _buildFallbackPoster(movie);
  }

  Widget _buildFallbackPoster(Movie movie) {
    final assetPath = movie.hinhAnh.startsWith('assets/')
        ? movie.hinhAnh
        : ImageUrlHelper.getLocalFallbackImage(movie.id);
    return Image.asset(
      assetPath,
      width: 75,
      height: 110,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        width: 75,
        height: 110,
        color: AppColors.darkSurfaceVariant,
        child: const Icon(Icons.movie_outlined, color: Colors.white38),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final favoriteList = HomeController.instance.danhSachYeuThich;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        elevation: 0,
        title: Text(
          'Phim Yêu Thích',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Làm mới danh sách',
            icon: Icon(
              Icons.refresh_rounded,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
            onPressed: () {
              setState(() {});
            },
          ),
        ],
      ),
      body: favoriteList.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border_rounded,
                    size: 80,
                    color: isDark
                        ? AppColors.darkTextMuted.withAlpha(120)
                        : AppColors.lightTextMuted.withAlpha(120),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có phim yêu thích nào',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Nhấn biểu tượng trái tim để thêm phim vào danh sách yêu thích!',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favoriteList.length,
              itemBuilder: (context, index) {
                final movie = favoriteList[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isDark ? AppColors.glassBorder : Colors.black12,
                    ),
                  ),
                  elevation: isDark ? 0 : 2,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () async {
                      await context.push(
                        RoutePath.movieDetailPath(movie.id.toString()),
                        extra: movie,
                      );
                      setState(() {});
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: _buildPoster(movie),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  movie.tenPhim,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.lightTextPrimary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryRed.withAlpha(38),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        movie.namPhatHanh.toString(),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primaryRed,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        movie.theLoai,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDark
                                              ? AppColors.darkTextMuted
                                              : AppColors.lightTextMuted,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      size: 16,
                                      color: AppColors.accentGold,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      movie.diemDanhGia.toStringAsFixed(1),
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? AppColors.darkTextPrimary
                                            : AppColors.lightTextPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.favorite,
                              color: AppColors.primaryRed,
                            ),
                            onPressed: () => _toggleFavorite(movie),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
