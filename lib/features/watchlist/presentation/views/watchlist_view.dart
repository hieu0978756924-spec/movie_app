import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/image_url_helper.dart';
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

class _WatchlistContent extends StatefulWidget {
  const _WatchlistContent();

  @override
  State<_WatchlistContent> createState() => _WatchlistContentState();
}

class _WatchlistContentState extends State<_WatchlistContent> {
  bool _isGridView = false;
  String _selectedSort = 'Mới thêm gần đây';

  final List<String> _sortOptions = [
    'Mới thêm gần đây',
    'Đánh giá cao nhất',
    'Tên (A-Z)',
  ];

  List<WatchlistItem> _sortItems(List<WatchlistItem> items) {
    final list = List<WatchlistItem>.from(items);
    if (_selectedSort == 'Đánh giá cao nhất') {
      list.sort((a, b) => b.diemDanhGia.compareTo(a.diemDanhGia));
    } else if (_selectedSort == 'Tên (A-Z)') {
      list.sort((a, b) => a.tenPhim.compareTo(b.tenPhim));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: (isDark ? AppColors.darkBackground : AppColors.lightBackground).withAlpha(200),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Watchlist Của Tôi',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
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
            final rawItems = state.items;

            if (rawItems.isEmpty) {
              return _buildEmptyState(context, isDark);
            }

            final items = _sortItems(rawItems);

            return RefreshIndicator(
              color: AppColors.primaryRed,
              onRefresh: () async {
                context.read<WatchlistBloc>().add(const LoadWatchlistEvent());
              },
              child: CustomScrollView(
                slivers: [
                  // Controls Row: Sort & Grid/List view toggle
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Sort Dropdown
                          PopupMenuButton<String>(
                            initialValue: _selectedSort,
                            onSelected: (val) {
                              setState(() {
                                _selectedSort = val;
                              });
                            },
                            itemBuilder: (context) {
                              return _sortOptions.map((opt) {
                                return PopupMenuItem<String>(
                                  value: opt,
                                  child: Text(
                                    opt,
                                    style: TextStyle(
                                      color: isDark ? Colors.white : Colors.black87,
                                      fontWeight: _selectedSort == opt
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                );
                              }).toList();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDark ? Colors.white.withAlpha(15) : Colors.black.withAlpha(12),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    _selectedSort,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Icon(
                                    Icons.expand_more_rounded,
                                    size: 18,
                                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Grid / List Toggle Button
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isGridView = !_isGridView;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(9),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDark ? Colors.white.withAlpha(15) : Colors.black.withAlpha(12),
                                ),
                              ),
                              child: Icon(
                                _isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
                                size: 20,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Watchlist Movies
                  if (_isGridView)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.62,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final item = items[index];
                            return _buildGridItem(context, item, isDark);
                          },
                          childCount: items.length,
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final item = items[index];
                            return _buildListItem(context, item, isDark);
                          },
                          childCount: items.length,
                        ),
                      ),
                    ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 32),
                  ),
                ],
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
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryRed.withAlpha(40),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.bookmark_outline_rounded,
                size: 72,
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
            const SizedBox(height: 28),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 6,
                shadowColor: AppColors.primaryRed.withAlpha(120),
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

  Widget _buildListItem(BuildContext context, WatchlistItem item, bool isDark) {
    final genres = item.theLoai.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    return Dismissible(
      key: Key('watchlist_item_${item.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline_rounded, color: Colors.white, size: 28),
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
            content: Text('Đã xóa "${item.tenPhim}" khỏi Watchlist'),
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
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white.withAlpha(15) : Colors.black.withAlpha(10),
          ),
        ),
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
                  child: _buildPoster(item.hinhAnh, width: 90, height: 130),
                ),
                const SizedBox(width: 14),

                // Details
                Expanded(
                  child: SizedBox(
                    height: 130,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.tenPhim,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),

                            // Subtitle info row (Year • Duration • Rating)
                            Row(
                              children: [
                                Text(
                                  item.namPhatHanh.toString(),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 6),
                                  width: 4,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                                  ),
                                ),
                                Text(
                                  '169m',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 6),
                                  width: 4,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      color: AppColors.accentGold,
                                      size: 15,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      item.diemDanhGia.toStringAsFixed(1),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.accentGold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            // Tags / Genre Chips
                            if (genres.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: genres.take(2).map((g) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: isDark ? Colors.white.withAlpha(12) : Colors.black.withAlpha(8),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isDark ? Colors.white.withAlpha(20) : Colors.black.withAlpha(15),
                                      ),
                                    ),
                                    child: Text(
                                      g,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ],
                        ),

                        // Actions Row (Delete button)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              tooltip: 'Xóa khỏi Watchlist',
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.white54,
                                size: 20,
                              ),
                              onPressed: () {
                                final bloc = context.read<WatchlistBloc>();
                                bloc.add(RemoveFromWatchlistEvent(item.id));
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGridItem(BuildContext context, WatchlistItem item, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withAlpha(15) : Colors.black.withAlpha(10),
        ),
      ),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster with overlay rating badge
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: _buildPoster(item.hinhAnh, width: double.infinity, height: double.infinity),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(180),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, color: AppColors.accentGold, size: 14),
                          const SizedBox(width: 2),
                          Text(
                            item.diemDanhGia.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
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
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.tenPhim,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.namPhatHanh.toString(),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          context.read<WatchlistBloc>().add(RemoveFromWatchlistEvent(item.id));
                        },
                        child: const Icon(
                          Icons.delete_outline_rounded,
                          size: 18,
                          color: Colors.white54,
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
    );
  }

  Widget _buildPoster(String path, {required double width, required double height}) {
    final posterUrl = ImageUrlHelper.getPosterUrl(path);
    if (posterUrl != null && posterUrl.startsWith('http')) {
      return Image.network(
        posterUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildFallbackPoster(width: width, height: height),
      );
    } else if (path.isNotEmpty) {
      return Image.asset(
        path.startsWith('assets/') ? path : ImageUrlHelper.getLocalFallbackImage(0),
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildFallbackPoster(width: width, height: height),
      );
    }
    return _buildFallbackPoster(width: width, height: height);
  }

  Widget _buildFallbackPoster({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      color: AppColors.darkSurfaceVariant,
      child: const Center(
        child: Icon(
          Icons.movie_outlined,
          color: AppColors.darkTextMuted,
          size: 32,
        ),
      ),
    );
  }
}
