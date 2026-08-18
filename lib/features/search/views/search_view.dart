import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/injection.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/image_url_helper.dart';
import '../../home/models/movie.dart';
import '../domain/entities/movie_filter.dart';
import '../presentation/bloc/search_bloc.dart';
import '../presentation/bloc/search_event.dart';
import '../presentation/bloc/search_state.dart';
import '../presentation/widgets/filter_bottom_sheet_widget.dart';

class SearchView extends StatelessWidget {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SearchBloc>(
      create: (_) => getIt<SearchBloc>()..add(const FetchGenresEvent()),
      child: const _SearchViewContent(),
    );
  }
}

class _SearchViewContent extends StatefulWidget {
  const _SearchViewContent();

  @override
  State<_SearchViewContent> createState() => _SearchViewContentState();
}

class _SearchViewContentState extends State<_SearchViewContent> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onClearSearch() {
    _searchController.clear();
    context.read<SearchBloc>().add(const ClearSearchEvent());
    setState(() {});
  }

  void _openFilterBottomSheet(SearchState state) {
    FilterBottomSheetWidget.show(
      context: context,
      initialFilter: state.filter,
      availableGenres: state.genres,
      onApply: (newFilter) {
        context.read<SearchBloc>().add(ApplyFilterEvent(newFilter));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        ),
        title: Text(
          'Tìm kiếm phim',
          style: TextStyle(
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
        actions: [
          BlocBuilder<SearchBloc, SearchState>(
            builder: (context, state) {
              final activeCount = state.filter.activeFilterCount;
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.tune_rounded,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                      onPressed: () => _openFilterBottomSheet(state),
                    ),
                    if (activeCount > 0)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.primaryRed,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '$activeCount',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Input Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? AppColors.glassBorder : AppColors.lightSurfaceVariant,
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: TextStyle(
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                      onChanged: (query) {
                        setState(() {});
                        context
                            .read<SearchBloc>()
                            .add(SearchQueryChangedEvent(query));
                      },
                      decoration: InputDecoration(
                        hintText: 'Nhập tên phim, diễn viên...',
                        hintStyle: TextStyle(
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AppColors.primaryRed,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.close_rounded,
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                ),
                                onPressed: _onClearSearch,
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Active Filter Bar (if filter is active)
          BlocBuilder<SearchBloc, SearchState>(
            builder: (context, state) {
              if (state.filter.isDefault) return const SizedBox.shrink();
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    const Icon(
                      Icons.filter_alt_outlined,
                      size: 16,
                      color: AppColors.accentGold,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _buildFilterSummaryText(state.filter),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        context.read<SearchBloc>().add(const ResetFilterEvent());
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Xoá lọc',
                        style: TextStyle(
                          color: AppColors.primaryRed,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 4),

          // Body content based on BLoC state
          Expanded(
            child: BlocBuilder<SearchBloc, SearchState>(
              builder: (context, state) {
                if (state is SearchInitialState) {
                  return _buildInitialState(isDark);
                } else if (state is SearchLoadingState) {
                  return _buildLoadingState();
                } else if (state is SearchLoadedState) {
                  return _buildSearchResultsGrid(state.movies, isDark);
                } else if (state is SearchEmptyState) {
                  return _buildEmptyState(state.query, state.filter, isDark);
                } else if (state is SearchErrorState) {
                  return _buildErrorState(state.message, isDark);
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  String _buildFilterSummaryText(MovieFilter filter) {
    final parts = <String>[];
    if (filter.selectedGenreIds.isNotEmpty) {
      parts.add('${filter.selectedGenreIds.length} thể loại');
    }
    if (filter.startYear > 1980 || filter.endYear < 2026) {
      parts.add('${filter.startYear}-${filter.endYear}');
    }
    if (filter.minRating > 0) {
      parts.add('≥ ${filter.minRating.toStringAsFixed(1)}★');
    }
    if (filter.sortBy != SortOption.popularityDesc) {
      parts.add(filter.sortBy.label);
    }
    return parts.join(' • ');
  }

  Widget _buildInitialState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.movie_filter_outlined,
            size: 72,
            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
          ),
          const SizedBox(height: 16),
          Text(
            'Tìm kiếm phim bạn yêu thích',
            style: TextStyle(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Nhập tên phim hoặc dùng nút bộ lọc ở trên',
            style: TextStyle(
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.primaryRed,
      ),
    );
  }

  Widget _buildSearchResultsGrid(List<Movie> movies, bool isDark) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.68,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: movies.length,
      itemBuilder: (context, index) {
        final movie = movies[index];
        final posterUrl = ImageUrlHelper.getPosterUrl(movie.hinhAnh);

        return GestureDetector(
          onTap: () {
            context.push(
              RoutePath.movieDetailPath(movie.id.toString()),
              extra: movie,
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightCard,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: isDark ? const Color(0x4D000000) : const Color(0x1F000000),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        posterUrl != null && posterUrl.startsWith('http')
                            ? Image.network(
                                posterUrl,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _buildFallbackPoster(isDark, movie.id),
                              )
                            : Image.asset(
                                movie.hinhAnh.startsWith('assets/')
                                    ? movie.hinhAnh
                                    : ImageUrlHelper.getLocalFallbackImage(movie.id),
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _buildFallbackPoster(isDark, movie.id),
                              ),
                        // Rating Badge
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xB3000000),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: AppColors.accentGold,
                                  size: 12,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  '${movie.diemDanhGia.toStringAsFixed(1)}/10',
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
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          movie.tenPhim,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          movie.theLoai.isNotEmpty ? movie.theLoai : 'Phim',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                            fontSize: 11,
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
    );
  }

  Widget _buildFallbackPoster(bool isDark, [int? movieId]) {
    return Image.asset(
      ImageUrlHelper.getLocalFallbackImage(movieId),
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
        child: Center(
          child: Icon(
            Icons.movie_outlined,
            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            size: 40,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String query, MovieFilter filter, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
            const SizedBox(height: 16),
            Text(
              'Không tìm thấy phim phù hợp',
              style: TextStyle(
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              query.isNotEmpty
                  ? 'Không có kết quả cho "$query" với bộ lọc đã chọn'
                  : 'Không có phim nào phù hợp với bộ lọc hiện tại',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                fontSize: 13,
              ),
            ),
            if (!filter.isDefault) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  context.read<SearchBloc>().add(const ResetFilterEvent());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryRed,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Xoá bộ lọc'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 56,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Đã có lỗi xảy ra',
              style: TextStyle(
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final currentQuery = _searchController.text;
                if (currentQuery.isNotEmpty) {
                  context
                      .read<SearchBloc>()
                      .add(SearchQueryChangedEvent(currentQuery));
                } else {
                  context.read<SearchBloc>().add(const ResetFilterEvent());
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}