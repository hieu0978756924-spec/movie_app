import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/models/movie.dart';
import '../../../home/views/movie_detail_view.dart';
import '../bloc/watchlist_bloc.dart';
import '../bloc/watchlist_event.dart';
import '../bloc/watchlist_state.dart';
import '../../domain/entities/watchlist_item.dart';

class WatchlistView extends StatelessWidget {
  const WatchlistView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<WatchlistBloc>(
      create: (_) => getIt<WatchlistBloc>()..add(const LoadWatchlistEvent()),
      child: const _WatchlistContent(),
    );
  }
}

class _WatchlistContent extends StatelessWidget {
  const _WatchlistContent();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        title: Text(
          'Danh sách xem sau',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        elevation: 0,
      ),
      body: BlocConsumer<WatchlistBloc, WatchlistState>(
        listener: (context, state) {
          if (state is WatchlistErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is WatchlistLoadingState) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryRed),
            );
          }

          if (state is WatchlistLoadedState) {
            final items = state.items;

            if (items.isEmpty) {
              return _buildEmptyState(context, isDark);
            }

            return RefreshIndicator(
              color: AppColors.primaryRed,
              onRefresh: () async {
                context.read<WatchlistBloc>().add(const LoadWatchlistEvent());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _buildDismissibleItem(context, item, isDark);
                },
              ),
            );
          }

          return _buildEmptyState(context, isDark);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryRed.withAlpha(25),
              ),
              child: const Icon(
                Icons.bookmark_outline_rounded,
                size: 80,
                color: AppColors.primaryRed,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Chưa có phim nào trong Watchlist',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Khám phá hàng ngàn bộ phim hấp dẫn và lưu vào danh sách xem sau của bạn.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                context.go(RoutePath.home);
              },
              icon: const Icon(Icons.explore_rounded),
              label: const Text(
                'Khám phá ngay',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDismissibleItem(
    BuildContext context,
    WatchlistItem item,
    bool isDark,
  ) {
    return Dismissible(
      key: Key('watchlist_item_${item.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline_rounded, color: Colors.white, size: 30),
            SizedBox(height: 4),
            Text(
              'Xóa',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      onDismissed: (direction) {
        final bloc = context.read<WatchlistBloc>();
        bloc.add(RemoveFromWatchlistEvent(item.id));

        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã xóa "${item.tenPhim}" khỏi danh sách'),
            action: SnackBarAction(
              label: 'Hoàn tác',
              textColor: AppColors.accentGold,
              onPressed: () {
                bloc.add(AddItemToWatchlistEvent(item));
              },
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
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
            final movie = Movie(
              id: item.id,
              tenPhim: item.tenPhim,
              hinhAnh: item.hinhAnh,
              backdropPath: item.backdropPath,
              diemDanhGia: item.diemDanhGia,
              theLoai: item.theLoai,
              moTa: '',
              namPhatHanh: item.namPhatHanh,
              yeuThich: true,
            );
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MovieDetailView(movie: movie),
              ),
            );
            if (context.mounted) {
              context.read<WatchlistBloc>().add(const LoadWatchlistEvent());
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Poster
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildPoster(item.hinhAnh),
                ),
                const SizedBox(width: 14),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.tenPhim,
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
                              item.namPhatHanh.toString(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryRed,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            item.theLoai,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.darkTextMuted
                                  : AppColors.lightTextMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: AppColors.accentGold,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.diemDanhGia.toStringAsFixed(1),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
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

                // Watched Checkbox Toggle
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      tooltip: item.daXem ? 'Chưa xem' : 'Đã xem',
                      icon: Icon(
                        item.daXem
                            ? Icons.check_circle_rounded
                            : Icons.check_circle_outline_rounded,
                        color: item.daXem
                            ? AppColors.success
                            : (isDark
                                ? AppColors.darkTextMuted
                                : AppColors.lightTextMuted),
                        size: 28,
                      ),
                      onPressed: () {
                        context.read<WatchlistBloc>().add(
                              ToggleWatchedEvent(
                                movieId: item.id,
                                daXem: !item.daXem,
                              ),
                            );
                      },
                    ),
                    Text(
                      item.daXem ? 'Đã xem' : 'Chưa xem',
                      style: TextStyle(
                        fontSize: 11,
                        color: item.daXem
                            ? AppColors.success
                            : (isDark
                                ? AppColors.darkTextMuted
                                : AppColors.lightTextMuted),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPoster(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        width: 80,
        height: 110,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildFallbackPoster(),
      );
    } else if (path.isNotEmpty) {
      return Image.asset(
        path,
        width: 80,
        height: 110,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildFallbackPoster(),
      );
    }
    return _buildFallbackPoster();
  }

  Widget _buildFallbackPoster() {
    return Container(
      width: 80,
      height: 110,
      color: AppColors.darkSurfaceVariant,
      child: const Icon(
        Icons.movie_outlined,
        color: AppColors.darkTextMuted,
        size: 36,
      ),
    );
  }
}
