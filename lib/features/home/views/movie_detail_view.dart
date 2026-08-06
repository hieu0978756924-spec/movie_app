import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/injection.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/image_url_helper.dart';
import '../models/movie.dart';
import '../presentation/bloc/movie_detail_bloc.dart';
import '../presentation/widgets/cast_section_widget.dart';
import '../presentation/widgets/trailer_player_dialog.dart';

class MovieDetailView extends StatefulWidget {
  final Movie movie;

  const MovieDetailView({
    super.key,
    required this.movie,
  });

  @override
  State<MovieDetailView> createState() => _MovieDetailViewState();
}

class _MovieDetailViewState extends State<MovieDetailView> {
  bool _isOverviewExpanded = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MovieDetailBloc>(
      create: (_) => getIt<MovieDetailBloc>()
        ..add(FetchMovieDetailEvent(
          widget.movie.id,
          initialMovie: widget.movie,
        )),
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: AppColors.darkBackground,
            body: BlocBuilder<MovieDetailBloc, MovieDetailState>(
              builder: (context, state) {
                Movie currentMovie = widget.movie;
                if (state is MovieDetailLoadedState) {
                  currentMovie = state.movie;
                } else if (state is MovieDetailLoadingState &&
                    state.initialMovie != null) {
                  currentMovie = state.initialMovie!;
                }

                final backdropUrl = ImageUrlHelper.getBackdropUrl(
                        currentMovie.backdropPath) ??
                    ImageUrlHelper.getPosterUrl(currentMovie.hinhAnh);
                final posterUrl =
                    ImageUrlHelper.getPosterUrl(currentMovie.hinhAnh);

                return CustomScrollView(
                  slivers: [
                    // Sliver App Bar with Backdrop Image
                    SliverAppBar(
                      expandedHeight: 320,
                      pinned: true,
                      backgroundColor: AppColors.darkBackground,
                      leading: IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_back,
                              color: Colors.white),
                        ),
                        onPressed: () => context.pop(),
                      ),
                      actions: [
                        IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              currentMovie.yeuThich
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: currentMovie.yeuThich
                                  ? AppColors.primaryRed
                                  : Colors.white,
                            ),
                          ),
                          onPressed: () {
                            context
                                .read<MovieDetailBloc>()
                                .add(ToggleFavoriteMovieEvent());
                          },
                        ),
                      ],
                      flexibleSpace: FlexibleSpaceBar(
                        background: Stack(
                          fit: StackFit.expand,
                          children: [
                            backdropUrl != null &&
                                    backdropUrl.startsWith('http')
                                ? Image.network(
                                    backdropUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        _buildFallbackBackdrop(),
                                  )
                                : Image.asset(
                                    currentMovie.hinhAnh.isNotEmpty
                                        ? currentMovie.hinhAnh
                                        : 'assets/images/latmat7.jpg',
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        _buildFallbackBackdrop(),
                                  ),
                            // Dark Gradient Fading to Bottom
                            Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black45,
                                    Colors.transparent,
                                    AppColors.darkBackground,
                                  ],
                                  stops: [0.0, 0.5, 1.0],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Main Content Body
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Poster & Title Info Header
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Poster Thumbnail Card
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: SizedBox(
                                    width: 110,
                                    height: 160,
                                    child: posterUrl != null &&
                                            posterUrl.startsWith('http')
                                        ? Image.network(
                                            posterUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                _buildFallbackPoster(),
                                          )
                                        : Image.asset(
                                            currentMovie.hinhAnh.isNotEmpty
                                                ? currentMovie.hinhAnh
                                                : 'assets/images/latmat7.jpg',
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                _buildFallbackPoster(),
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Title Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        currentMovie.tenPhim,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (currentMovie.daoDien.isNotEmpty) ...[
                                        const SizedBox(height: 6),
                                        Text(
                                          currentMovie.daoDien,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 13,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.star,
                                            color: AppColors.accentGold,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            currentMovie.diemDanhGia
                                                .toStringAsFixed(1),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          if (currentMovie.voteCount > 0) ...[
                                            const SizedBox(width: 4),
                                            Text(
                                              '(${currentMovie.voteCount} votes)',
                                              style: const TextStyle(
                                                color: Colors.white54,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.calendar_today,
                                            color: Colors.white54,
                                            size: 14,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            currentMovie.namPhatHanh.toString(),
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 13,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          const Icon(
                                            Icons.access_time,
                                            color: Colors.white54,
                                            size: 14,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            currentMovie.thoiLuong,
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Genre Chips
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: currentMovie.theLoai
                                  .split(',')
                                  .map(
                                    (genre) => Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: AppColors.darkSurfaceVariant,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                            color: Colors.white12),
                                      ),
                                      child: Text(
                                        genre.trim(),
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                            const SizedBox(height: 24),

                            // Action Button: Watch Trailer
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryRed,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () {
                                  String? trailerKey;
                                  if (state is MovieDetailLoadedState &&
                                      state.trailers.isNotEmpty) {
                                    final youtubeTrailer =
                                        state.trailers.firstWhere(
                                      (v) =>
                                          v.site.toLowerCase() == 'youtube' &&
                                          (v.type.toLowerCase() == 'trailer' ||
                                              v.type.toLowerCase() == 'teaser'),
                                      orElse: () => state.trailers.first,
                                    );
                                    if (youtubeTrailer.key.isNotEmpty) {
                                      trailerKey = youtubeTrailer.key;
                                    }
                                  }

                                  if (trailerKey != null &&
                                      trailerKey.isNotEmpty) {
                                    TrailerPlayerDialog.show(
                                      context,
                                      youtubeKey: trailerKey,
                                      title: currentMovie.tenPhim,
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        backgroundColor: AppColors.darkSurface,
                                        content: Text(
                                          'Không tìm thấy trailer cho phim này',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(
                                  Icons.play_arrow,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                label: const Text(
                                  'Xem Trailer',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Overview Section
                            const Text(
                              'Nội dung phim',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              currentMovie.moTa,
                              maxLines: _isOverviewExpanded ? null : 4,
                              overflow: _isOverviewExpanded
                                  ? TextOverflow.visible
                                  : TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 15,
                                height: 1.5,
                              ),
                            ),
                            if (currentMovie.moTa.length > 150)
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isOverviewExpanded =
                                        !_isOverviewExpanded;
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    _isOverviewExpanded
                                        ? 'Thu gọn'
                                        : 'Xem thêm',
                                    style: const TextStyle(
                                      color: AppColors.primaryRed,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 24),
                            if (state is MovieDetailLoadedState) ...[
                              CastSectionWidget(castList: state.castList),
                            ],
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildFallbackBackdrop() {
    return Container(
      color: AppColors.darkSurfaceVariant,
      child: const Center(
        child: Icon(
          Icons.movie_outlined,
          color: Colors.white38,
          size: 64,
        ),
      ),
    );
  }

  Widget _buildFallbackPoster() {
    return Container(
      color: AppColors.darkSurfaceVariant,
      child: const Center(
        child: Icon(
          Icons.local_movies_outlined,
          color: Colors.white38,
          size: 32,
        ),
      ),
    );
  }
}