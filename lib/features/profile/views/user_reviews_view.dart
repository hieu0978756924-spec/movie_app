import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/injection.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/image_url_helper.dart';
import '../../home/controllers/home_controller.dart';
import '../../home/models/movie.dart';
import '../../review/data/datasources/user_review_manager.dart';
import '../../review/domain/repositories/review_repository.dart';
import '../../review/presentation/widgets/write_review_bottom_sheet.dart';

class UserReviewsView extends StatelessWidget {
  const UserReviewsView({super.key});

  void _confirmDeleteReview(
      BuildContext context, int movieId, String movieTitle) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xác nhận xóa',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(
          'Bạn có chắc chắn muốn xóa đánh giá của phim "$movieTitle" không?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await getIt<ReviewRepository>().deleteReview(movieId: movieId);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã xóa đánh giá của bạn!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _navigateToMovie(
      BuildContext context, int movieId, String? title, String? poster) {
    final cachedMovie = HomeController.instance.getMovieById(movieId);
    Movie targetMovie;
    if (cachedMovie != null &&
        (title == null ||
            cachedMovie.tenPhim.toLowerCase() == title.toLowerCase())) {
      targetMovie = cachedMovie;
    } else {
      targetMovie = Movie(
        id: movieId,
        tenPhim: title ?? (cachedMovie?.tenPhim ?? 'Phim #$movieId'),
        hinhAnh: poster ??
            (cachedMovie?.hinhAnh ??
                ImageUrlHelper.getLocalFallbackImage(movieId)),
        theLoai: 'Chi tiết phim',
        diemDanhGia: 8.0,
        thoiLuong: '120 min',
        moTa: 'Thông tin chi tiết phim ${title ?? ''}',
        namPhatHanh: 2024,
        daoDien: 'Đang cập nhật',
      );
    }

    try {
      context.push(
        RoutePath.movieDetailPath(movieId.toString()),
        extra: targetMovie,
      );
    } catch (_) {
      context.pushNamed(
        RouteName.movieDetail,
        pathParameters: {'id': movieId.toString()},
        extra: targetMovie,
      );
    }
  }

  Widget _buildPoster(String? posterPath, int movieId, bool isDark) {
    final resolvedUrl = ImageUrlHelper.getPosterUrl(posterPath);
    if (resolvedUrl != null &&
        (resolvedUrl.startsWith('http://') ||
            resolvedUrl.startsWith('https://'))) {
      return Image.network(
        resolvedUrl,
        width: 75,
        height: 110,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            _buildLocalPosterFallback(posterPath, movieId, isDark),
      );
    }
    return _buildLocalPosterFallback(posterPath, movieId, isDark);
  }

  Widget _buildLocalPosterFallback(String? path, int movieId, bool isDark) {
    final localPath = (path != null && path.startsWith('assets/'))
        ? path
        : ImageUrlHelper.getLocalFallbackImage(movieId);
    return Image.asset(
      localPath,
      width: 75,
      height: 110,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        width: 75,
        height: 110,
        color: isDark
            ? AppColors.darkSurfaceVariant
            : AppColors.lightSurfaceVariant,
        child: const Icon(Icons.movie_rounded, color: Colors.grey),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: isDark ? Colors.white : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Đánh Giá Của Tôi',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: ValueListenableBuilder<Map<int, UserReviewItem>>(
        valueListenable: UserReviewManager.instance.userReviewsNotifier,
        builder: (context, reviewsMap, _) {
          final reviewsList = reviewsMap.values.toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

          if (reviewsList.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.accentGold.withAlpha(25),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.rate_review_outlined,
                        size: 64,
                        color: AppColors.accentGold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Bạn chưa có đánh giá nào',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hãy xem phim và chia sẻ cảm nhận, chấm điểm cho các tác phẩm yêu thích của bạn nhé!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white60 : Colors.black54,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        context.go(RoutePath.home);
                      },
                      icon: const Icon(Icons.explore_rounded),
                      label: const Text('Khám phá phim ngay'),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tất cả bình luận & đánh giá (${reviewsList.length})',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accentGold.withAlpha(25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '⭐ ${reviewsList.length} phim',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accentGold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: reviewsList.length,
                  itemBuilder: (context, index) {
                    final item = reviewsList[index];
                    final cachedMovie =
                        HomeController.instance.getMovieById(item.movieId);
                    final movieTitle = item.movieTitle ??
                        (cachedMovie != null
                            ? cachedMovie.tenPhim
                            : 'Phim #${item.movieId}');
                    final moviePoster =
                        item.moviePoster ?? cachedMovie?.hinhAnh;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color:
                            isDark ? AppColors.darkCard : AppColors.lightCard,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.accentGold.withAlpha(100),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isDark ? Colors.black45 : Colors.black12,
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Row: Poster + Title + Rating
                            InkWell(
                              onTap: () => _navigateToMovie(context,
                                  item.movieId, movieTitle, moviePoster),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: _buildPoster(
                                          moviePoster, item.movieId, isDark),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            movieTitle,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: isDark
                                                  ? Colors.white
                                                  : Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: AppColors.accentGold
                                                  .withAlpha(30),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.star_rounded,
                                                  color: AppColors.accentGold,
                                                  size: 16,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${item.rating.toStringAsFixed(1)} / 10',
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.accentGold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            _formatDate(item.createdAt),
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: isDark
                                                  ? AppColors.darkTextMuted
                                                  : AppColors.lightTextMuted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Review Content Area
                            Container(
                              width: double.infinity,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.black.withAlpha(80)
                                    : Colors.grey.withAlpha(20),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.format_quote_rounded,
                                          color: AppColors.accentGold,
                                          size: 16),
                                      SizedBox(width: 4),
                                      Text(
                                        'Bình luận của bạn:',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.accentGold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    item.content,
                                    style: TextStyle(
                                      fontSize: 14,
                                      height: 1.4,
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Bottom Actions Row
                            Padding(
                              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton.icon(
                                    onPressed: () => _confirmDeleteReview(
                                        context, item.movieId, movieTitle),
                                    icon: const Icon(
                                        Icons.delete_outline_rounded,
                                        color: Colors.redAccent,
                                        size: 18),
                                    label: const Text('Xóa',
                                        style: TextStyle(
                                            color: Colors.redAccent,
                                            fontSize: 13)),
                                  ),
                                  const SizedBox(width: 8),
                                  TextButton.icon(
                                    onPressed: () {
                                      WriteReviewBottomSheet.show(
                                        context,
                                        movieId: item.movieId,
                                        movieTitle: movieTitle,
                                        moviePoster: moviePoster,
                                      );
                                    },
                                    icon: const Icon(Icons.edit_note_rounded,
                                        color: AppColors.accentGold, size: 18),
                                    label: const Text('Chỉnh sửa',
                                        style: TextStyle(
                                            color: AppColors.accentGold,
                                            fontSize: 13)),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryRed,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                    ),
                                    onPressed: () => _navigateToMovie(context,
                                        item.movieId, movieTitle, moviePoster),
                                    icon: const Icon(Icons.play_arrow_rounded,
                                        size: 18),
                                    label: const Text('Xem ngay',
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ],
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
          );
        },
      ),
    );
  }
}
