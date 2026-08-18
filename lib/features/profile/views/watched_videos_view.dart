import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/image_url_helper.dart';
import '../data/watch_history_manager.dart';

class WatchedVideosView extends StatelessWidget {
  const WatchedVideosView({super.key});

  void _confirmClearHistory(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa toàn bộ lịch sử video đã xem không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryRed),
            onPressed: () {
              WatchHistoryManager.instance.clearHistory();
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã xóa toàn bộ lịch sử xem video!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Xóa tất cả', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _removeItem(BuildContext context, int index, String movieTitle) {
    WatchHistoryManager.instance.removeItemAt(index);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã xóa "$movieTitle" khỏi lịch sử xem'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildPosterImage(String hinhAnhPath, int movieId, bool isDark) {
    final posterUrl = ImageUrlHelper.getPosterUrl(hinhAnhPath);
    if (posterUrl != null && posterUrl.startsWith('http')) {
      return Image.network(
        posterUrl,
        width: 80,
        height: 115,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildLocalPosterFallback(hinhAnhPath, movieId, isDark),
      );
    }
    return _buildLocalPosterFallback(hinhAnhPath, movieId, isDark);
  }

  Widget _buildLocalPosterFallback(String path, int movieId, bool isDark) {
    final localPath = path.startsWith('assets/') ? path : ImageUrlHelper.getLocalFallbackImage(movieId);
    return Image.asset(
      localPath,
      width: 80,
      height: 115,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        width: 80,
        height: 115,
        color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
        child: const Icon(Icons.movie, color: Colors.grey),
      ),
    );
  }

  Widget _buildBackdropBanner(String? backdropPath, int movieId, bool isDark) {
    final backdropUrl = ImageUrlHelper.getBackdropUrl(backdropPath);
    if (backdropUrl != null && backdropUrl.startsWith('http')) {
      return Image.network(
        backdropUrl,
        width: double.infinity,
        height: 90,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildLocalBackdropFallback(backdropPath, movieId, isDark),
      );
    }
    return _buildLocalBackdropFallback(backdropPath, movieId, isDark);
  }

  Widget _buildLocalBackdropFallback(String? path, int movieId, bool isDark) {
    final localPath = (path != null && path.startsWith('assets/'))
        ? path
        : ImageUrlHelper.getLocalFallbackImage(movieId);
    return Image.asset(
      localPath,
      width: double.infinity,
      height: 90,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        width: double.infinity,
        height: 90,
        color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ValueListenableBuilder<List<WatchedVideoItem>>(
      valueListenable: WatchHistoryManager.instance.history,
      builder: (context, watchedList, child) {
        return Scaffold(
          backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
          appBar: AppBar(
            backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            elevation: 0,
            title: Text(
              'Video đã xem',
              style: TextStyle(
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            iconTheme: IconThemeData(
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
            actions: [
              if (watchedList.isNotEmpty)
                IconButton(
                  tooltip: 'Xóa toàn bộ lịch sử',
                  icon: const Icon(Icons.delete_sweep_outlined, color: AppColors.error),
                  onPressed: () => _confirmClearHistory(context),
                ),
            ],
          ),
          body: watchedList.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history_outlined,
                        size: 80,
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Bạn chưa xem video nào gần đây',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: watchedList.length,
                  itemBuilder: (context, index) {
                    final item = watchedList[index];
                    final movie = item.movie;

                    return Dismissible(
                      key: Key('watched_${movie.id}_$index'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
                      ),
                      onDismissed: (_) => _removeItem(context, index, movie.tenPhim),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCard : AppColors.lightCard,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: isDark
                              ? []
                              : [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(12),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () {
                            try {
                              context.pushNamed(
                                RouteName.movieDetail,
                                pathParameters: {'id': movie.id.toString()},
                                extra: movie,
                              );
                            } catch (_) {
                              context.push(
                                RoutePath.movieDetailPath(movie.id.toString()),
                                extra: movie,
                              );
                            }
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Top Banner / Backdrop Synchronized Header
                              Stack(
                                children: [
                                  _buildBackdropBanner(movie.backdropPath, movie.id, isDark),
                                  Container(
                                    height: 90,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          (isDark ? AppColors.darkCard : AppColors.lightCard)
                                              .withAlpha(220),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: IconButton(
                                      icon: const Icon(Icons.close, color: Colors.white, size: 20),
                                      style: IconButton.styleFrom(
                                        backgroundColor: Colors.black.withAlpha(140),
                                        padding: const EdgeInsets.all(4),
                                      ),
                                      onPressed: () => _removeItem(context, index, movie.tenPhim),
                                    ),
                                  ),
                                ],
                              ),

                              // Movie Details & Poster Row
                              Padding(
                                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Synchronized Poster Thumbnail
                                    Transform.translate(
                                      offset: const Offset(0, -24),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Stack(
                                          children: [
                                            _buildPosterImage(movie.hinhAnh, movie.id, isDark),
                                            Positioned.fill(
                                              child: Container(
                                                color: Colors.black.withAlpha(50),
                                                child: const Center(
                                                  child: Icon(
                                                    Icons.play_circle_fill,
                                                    color: AppColors.primaryRed,
                                                    size: 32,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),

                                    // Details Column
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 4),
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
                                              const Icon(
                                                Icons.star_rounded,
                                                size: 16,
                                                color: AppColors.accentGold,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${movie.diemDanhGia.toStringAsFixed(1)}/10',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: isDark
                                                      ? AppColors.darkTextPrimary
                                                      : AppColors.lightTextPrimary,
                                                ),
                                              ),
                                              const SizedBox(width: 10),
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
                                              Icon(
                                                Icons.access_time_rounded,
                                                size: 14,
                                                color: isDark
                                                    ? AppColors.darkTextMuted
                                                    : AppColors.lightTextMuted,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                item.watchedAt,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: isDark
                                                      ? AppColors.darkTextMuted
                                                      : AppColors.lightTextMuted,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),

                                          // Progress Bar
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(4),
                                                child: LinearProgressIndicator(
                                                  value: item.progress,
                                                  backgroundColor: isDark
                                                      ? AppColors.darkSurfaceVariant
                                                      : AppColors.lightSurfaceVariant,
                                                  valueColor: const AlwaysStoppedAnimation<Color>(
                                                    AppColors.primaryRed,
                                                  ),
                                                  minHeight: 4,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Đã xem ${(item.progress * 100).toInt()}%',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: isDark
                                                      ? AppColors.darkTextMuted
                                                      : AppColors.lightTextMuted,
                                                ),
                                              ),
                                            ],
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
                ),
        );
      },
    );
  }
}
