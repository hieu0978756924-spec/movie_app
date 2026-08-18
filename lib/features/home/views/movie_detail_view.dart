import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../core/di/injection.dart';
import '../../../core/router/route_names.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';


import '../../../core/utils/image_url_helper.dart';
import '../../../core/utils/user_session.dart';
import '../../../core/utils/youtube_utils.dart';
import '../controllers/home_controller.dart';
import '../domain/entities/cast.dart';
import '../models/movie.dart';

import '../presentation/bloc/movie_detail_bloc.dart';
import '../presentation/widgets/movie_section_widget.dart';
import '../../review/presentation/widgets/review_list_widget.dart';
import '../../profile/data/watch_history_manager.dart';

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
  bool _isPlayingTrailer = false;
  YoutubePlayerController? _youtubeController;
  String? _currentTrailerKey;

  void _playTrailerInline(String youtubeKey, [Movie? movie]) {
    final targetMovie = movie ?? widget.movie;
    final keyToPlay = youtubeKey.trim();

    WatchHistoryManager.instance.addWatchedVideo(targetMovie);

    if (keyToPlay.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Trailer cho phim "${targetMovie.tenPhim}" chưa có sẵn.'),
            backgroundColor: AppColors.primaryRed,
          ),
        );
      }
      return;
    }

    if (_currentTrailerKey != keyToPlay || _youtubeController == null) {
      _youtubeController?.dispose();
      _currentTrailerKey = keyToPlay;
      _youtubeController = YoutubePlayerController(
        initialVideoId: keyToPlay,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
          enableCaption: true,
          isLive: false,
          forceHD: false,
        ),
      );
    } else {
      _youtubeController?.play();
    }
    
    if (mounted) {
      setState(() {
        _isPlayingTrailer = true;
      });
    }
  }

  String _getTmdbTrailerKey(MovieDetailState state) {
    if (state is MovieDetailLoadedState && state.trailers.isNotEmpty) {
      final officialTrailer = state.trailers.firstWhere(
        (v) =>
            v.site.toLowerCase() == 'youtube' &&
            v.type.toLowerCase() == 'trailer' &&
            (v.official == true || v.name.toLowerCase().contains('official')),
        orElse: () => state.trailers.firstWhere(
          (v) =>
              v.site.toLowerCase() == 'youtube' &&
              (v.type.toLowerCase() == 'trailer' ||
                  v.type.toLowerCase() == 'teaser'),
          orElse: () => state.trailers.firstWhere(
            (v) => v.site.toLowerCase() == 'youtube',
            orElse: () => state.trailers.first,
          ),
        ),
      );
      final key = YoutubeUtils.extractYoutubeKey(officialTrailer.key);
      if (key.isNotEmpty) {
        return key;
      }
    }

    final fromWidgetMovie = YoutubeUtils.extractYoutubeKey(widget.movie.trailerUrl);
    if (fromWidgetMovie.isNotEmpty) {
      return fromWidgetMovie;
    }

    if (state is MovieDetailLoadedState) {
      final fromStateMovie = YoutubeUtils.extractYoutubeKey(state.movie.trailerUrl);
      if (fromStateMovie.isNotEmpty) {
        return fromStateMovie;
      }
    }

    return YoutubeUtils.getFallbackTrailerKeyForMovieId(widget.movie.id);
  }  @override
  void dispose() {
    _youtubeController?.dispose();
    super.dispose();
  }

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
          final isDark = Theme.of(context).brightness == Brightness.dark;

          return Scaffold(
            backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
            body: MultiBlocListener(
              listeners: [
                BlocListener<MovieDetailBloc, MovieDetailState>(
                  listenWhen: (previous, current) {
                    bool? prevFav;
                    bool? currFav;
                    if (previous is MovieDetailLoadedState) {
                      prevFav = previous.movie.yeuThich;
                    } else if (previous is MovieDetailLoadingState &&
                        previous.initialMovie != null) {
                      prevFav = previous.initialMovie!.yeuThich;
                    }

                    if (current is MovieDetailLoadedState) {
                      currFav = current.movie.yeuThich;
                    } else if (current is MovieDetailLoadingState &&
                        current.initialMovie != null) {
                      currFav = current.initialMovie!.yeuThich;
                    }

                    if (prevFav != null && currFav != null) {
                      return prevFav != currFav;
                    }
                    return false;
                  },
                  listener: (context, state) {
                    Movie? movie;
                    if (state is MovieDetailLoadedState) {
                      movie = state.movie;
                    } else if (state is MovieDetailLoadingState &&
                        state.initialMovie != null) {
                      movie = state.initialMovie;
                    }

                    if (movie != null) {
                      final isFav = movie.yeuThich;
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          duration: const Duration(seconds: 2),
                          backgroundColor: isDark
                              ? AppColors.darkSurface
                              : AppColors.lightSurfaceVariant,
                          content: Row(
                            children: [
                              Icon(
                                isFav
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isFav
                                    ? AppColors.primaryRed
                                    : (isDark
                                        ? Colors.white70
                                        : AppColors.lightTextSecondary),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  isFav
                                      ? 'Đã thêm "${movie.tenPhim}" vào danh sách yêu thích'
                                      : 'Đã xóa "${movie.tenPhim}" khỏi danh sách yêu thích',
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white
                                        : AppColors.lightTextPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                ),
                BlocListener<MovieDetailBloc, MovieDetailState>(
                  listenWhen: (previous, current) {
                    if (previous is MovieDetailLoadedState &&
                        current is MovieDetailLoadedState) {
                      return previous.isWatchlisted != current.isWatchlisted;
                    }
                    return false;
                  },
                  listener: (context, state) {
                    if (state is MovieDetailLoadedState) {
                      final isSaved = state.isWatchlisted;
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          duration: const Duration(seconds: 2),
                          backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurfaceVariant,
                          content: Row(
                            children: [
                              Icon(
                                isSaved
                                    ? Icons.bookmark_rounded
                                    : Icons.bookmark_outline_rounded,
                                color:
                                    isSaved ? AppColors.deepPink : (isDark ? Colors.white70 : AppColors.lightTextSecondary),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                    isSaved
                                        ? 'Đã thêm "${state.movie.tenPhim}" vào Watchlist'
                                        : 'Đã xóa "${state.movie.tenPhim}" khỏi Watchlist',
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white
                                          : AppColors.lightTextPrimary,
                                    ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
              child: BlocBuilder<MovieDetailBloc, MovieDetailState>(
              builder: (context, state) {
                final locale = AppLocalizations.of(context);
                Movie currentMovie = widget.movie;

                final indexInHome = HomeController.instance.danhSachPhim.indexWhere((m) => m.id == widget.movie.id);
                if (indexInHome != -1) {
                  currentMovie = currentMovie.copyWith(yeuThich: HomeController.instance.danhSachPhim[indexInHome].yeuThich);
                }
                bool isWatchlisted = false;
                List<Movie> similarMoviesList = [];
                if (state is MovieDetailLoadedState) {
                  isWatchlisted = state.isWatchlisted;
                  similarMoviesList = state.similarMovies;
                  currentMovie = state.movie.copyWith(

                    hinhAnh: widget.movie.hinhAnh.startsWith('assets/')
                        ? widget.movie.hinhAnh
                        : state.movie.hinhAnh,
                  );
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
                      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
                      leading: IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.black54 : Colors.grey.withAlpha(40),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.arrow_back,
                              color: isDark ? Colors.white : Colors.black87),
                        ),
                        onPressed: () => context.pop(),
                      ),
                      actions: [
                        IconButton(
                          tooltip: 'Thêm vào watchlist',
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.black54 : Colors.grey.withAlpha(40),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isWatchlisted
                                  ? Icons.bookmark_rounded
                                  : Icons.bookmark_outline_rounded,
                              color: isWatchlisted
                                  ? AppColors.deepPink
                                  : (isDark ? Colors.white : Colors.black87),
                            ),
                          ),
                          onPressed: () {
                            UserSession.instance.requireAuth(
                              context,
                              actionName: 'thêm phim vào watchlist',
                              onAuthenticated: () {
                                context
                                    .read<MovieDetailBloc>()
                                    .add(ToggleWatchlistMovieEvent());
                              },
                            );
                          },
                        ),
                        IconButton(
                          tooltip: 'Yêu thích',
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.black54 : Colors.grey.withAlpha(40),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              currentMovie.yeuThich
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: currentMovie.yeuThich
                                  ? AppColors.primaryRed
                                  : (isDark ? Colors.white : Colors.black87),
                            ),
                          ),
                          onPressed: () {
                            UserSession.instance.requireAuth(
                              context,
                              actionName: 'thêm phim vào danh sách yêu thích',
                              onAuthenticated: () {
                                context
                                    .read<MovieDetailBloc>()
                                    .add(ToggleFavoriteMovieEvent());
                              },
                            );
                          },
                        ),
                      ],
                        flexibleSpace: FlexibleSpaceBar(
                          background: Stack(
                            fit: StackFit.expand,
                            children: [
                              if (_isPlayingTrailer && _youtubeController != null) ...[
                                YoutubePlayer(
                                  controller: _youtubeController!,
                                  showVideoProgressIndicator: true,
                                  progressIndicatorColor: AppColors.primaryRed,
                                  progressColors: const ProgressBarColors(
                                    playedColor: AppColors.primaryRed,
                                    handleColor: AppColors.primaryRed,
                                  ),
                                  onReady: () {
                                    _youtubeController?.unMute();
                                    _youtubeController?.setVolume(100);
                                  },
                                ),
                              ] else ...[
                                backdropUrl != null &&
                                        backdropUrl.startsWith('http')
                                    ? Image.network(
                                        backdropUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            _buildFallbackBackdrop(currentMovie),
                                      )
                                    : Image.asset(
                                        currentMovie.hinhAnh.startsWith('assets/')
                                            ? currentMovie.hinhAnh
                                            : ImageUrlHelper.getLocalFallbackImage(currentMovie.id),
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            _buildFallbackBackdrop(currentMovie),
                                      ),
                                // Dark Gradient Fading to Bottom
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.black45,
                                        Colors.transparent,
                                        isDark ? AppColors.darkBackground : AppColors.lightBackground,
                                      ],
                                      stops: const [0.0, 0.5, 1.0],
                                    ),
                                  ),
                                ),
                                // Center Play Button Overlay
                                Center(
                                  child: GestureDetector(
                                    onTap: () {
                                      UserSession.instance.requireAuth(
                                        context,
                                        actionName: 'xem trailer phim',
                                        onAuthenticated: () {
                                          final key = _getTmdbTrailerKey(state);
                                          _playTrailerInline(key, currentMovie);
                                        },
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: const BoxDecoration(
                                        color: AppColors.primaryRed,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black45,
                                            blurRadius: 12,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.play_arrow_rounded,
                                        color: Colors.white,
                                        size: 40,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
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
                                                _buildFallbackPoster(currentMovie),
                                          )
                                        : Image.asset(
                                            currentMovie.hinhAnh.startsWith('assets/')
                                                ? currentMovie.hinhAnh
                                                : ImageUrlHelper.getLocalFallbackImage(currentMovie.id),
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                _buildFallbackPoster(currentMovie),
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
                                        style: TextStyle(
                                          color: isDark ? Colors.white : AppColors.lightTextPrimary,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
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
                                            '${currentMovie.diemDanhGia.toStringAsFixed(1)} / 10',

                                            style: TextStyle(
                                              color: isDark ? Colors.white : AppColors.lightTextPrimary,
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          if (currentMovie.voteCount > 0) ...[
                                            const SizedBox(width: 4),
                                            Text(
                                              '(${currentMovie.voteCount} votes)',
                                              style: TextStyle(
                                                color: isDark ? Colors.white54 : AppColors.lightTextMuted,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_today,
                                            color: isDark ? Colors.white54 : AppColors.lightTextMuted,
                                            size: 14,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            currentMovie.namPhatHanh.toString(),
                                            style: TextStyle(
                                              color: isDark ? Colors.white70 : AppColors.lightTextSecondary,
                                              fontSize: 13,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Icon(
                                            Icons.access_time,
                                            color: isDark ? Colors.white54 : AppColors.lightTextMuted,
                                            size: 14,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            currentMovie.thoiLuong,
                                            style: TextStyle(
                                              color: isDark ? Colors.white70 : AppColors.lightTextSecondary,
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
                                        color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                            color: isDark ? Colors.white12 : Colors.black12),
                                      ),
                                      child: Text(
                                        genre.trim(),
                                        style: TextStyle(
                                          color: isDark ? Colors.white70 : AppColors.lightTextSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                            const SizedBox(height: 20),

                             // Action Buttons: Watchlist & Xem Ngay (Bằng nhau 50-50)
                            SizedBox(
                              width: double.infinity,
                              child: Row(
                                children: [
                                  // Nút Lưu Watchlist
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isWatchlisted
                                            ? AppColors.deepPink
                                            : (isDark
                                                ? AppColors.darkSurfaceVariant
                                                : AppColors.lightSurfaceVariant),
                                        foregroundColor: isWatchlisted
                                            ? Colors.white
                                            : AppColors.deepPink,
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(14),
                                          side: isWatchlisted
                                              ? BorderSide.none
                                              : const BorderSide(
                                                  color: AppColors.deepPink,
                                                  width: 1.5),
                                        ),
                                        elevation: 4,
                                        shadowColor: AppColors.deepPink.withAlpha(100),
                                      ),
                                      onPressed: () {
                                        UserSession.instance.requireAuth(
                                          context,
                                          actionName: isWatchlisted
                                              ? 'bỏ lưu phim khỏi Watchlist'
                                              : 'lưu phim vào Watchlist',
                                          onAuthenticated: () {
                                            context
                                                .read<MovieDetailBloc>()
                                                .add(ToggleWatchlistMovieEvent());
                                          },
                                        );
                                      },
                                      icon: Icon(
                                        isWatchlisted
                                            ? Icons.bookmark_rounded
                                            : Icons.bookmark_outline_rounded,
                                        color: isWatchlisted
                                            ? Colors.white
                                            : AppColors.deepPink,
                                        size: 20,
                                      ),
                                      label: Text(
                                        isWatchlisted
                                            ? 'Đã lưu Watchlist'
                                            : 'Thêm Watchlist',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: isWatchlisted ? Colors.white : AppColors.deepPink,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Nút Xem Ngay
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primaryRed,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        elevation: 4,
                                        shadowColor: AppColors.primaryRed.withAlpha(100),
                                      ),
                                      onPressed: () {
                                        UserSession.instance.requireAuth(
                                          context,
                                          actionName: 'xem phim',
                                          onAuthenticated: () {
                                            String dedicatedMovieKey = _getTmdbTrailerKey(state);
                                            if (dedicatedMovieKey.isEmpty) {
                                              dedicatedMovieKey = 'ARA6Bfqfo8c'; // Doraemon trailer fallback key
                                            }
                                            _playTrailerInline(dedicatedMovieKey, currentMovie);
                                            context.pushNamed(
                                              RouteName.moviePlayer,
                                              pathParameters: {'id': currentMovie.id.toString()},
                                              extra: {
                                                'movie': currentMovie,
                                                'key': dedicatedMovieKey,
                                              },
                                            );
                                          },
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.play_arrow_rounded,
                                        color: Colors.white,
                                        size: 22,
                                      ),
                                      label: const Text(
                                        'Xem Ngay',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                                    // Overview Section
                            Text(
                              locale.translate('synopsis'),
                              style: TextStyle(
                                color: isDark ? Colors.white : AppColors.lightTextPrimary,
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
                              style: TextStyle(
                                color: isDark ? Colors.white70 : AppColors.lightTextSecondary,
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
                                        ? locale.translate('show_less')
                                        : locale.translate('see_more'),
                                    style: const TextStyle(
                                      color: AppColors.primaryRed,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 24),

                            // Cast & Crew Section
                            Text(
                              locale.translate('cast'),
                              style: TextStyle(
                                color: isDark ? Colors.white : AppColors.lightTextPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),


                            SizedBox(
                              height: 140,
                              child: Builder(
                                builder: (context) {
                                  List<Cast> apiCastList = [];
                                  if (state is MovieDetailLoadedState &&
                                      state.castList.isNotEmpty) {
                                    apiCastList = state.castList;
                                  }

                                  if (apiCastList.isNotEmpty) {
                                    return ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: apiCastList.length,
                                      itemBuilder: (context, index) {
                                        final castItem = apiCastList[index];
                                        final imgUrl = ImageUrlHelper.getProfileUrl(castItem.profilePath);

                                        return GestureDetector(
                                          onTap: () {
                                            context.push(RoutePath.actorPath(castItem.id));
                                          },
                                          child: Container(
                                            width: 90,
                                            margin: const EdgeInsets.only(right: 14),
                                            child: Column(
                                              children: [
                                                CircleAvatar(
                                                  radius: 34,
                                                  backgroundColor: AppColors.darkSurfaceVariant,
                                                  child: ClipOval(
                                                    child: imgUrl != null
                                                        ? Image.network(
                                                            imgUrl,
                                                            width: 68,
                                                            height: 68,
                                                            fit: BoxFit.cover,
                                                            errorBuilder: (_, __, ___) => Image.asset(
                                                              'assets/images/actor_1.jpg',
                                                              width: 68,
                                                              height: 68,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          )
                                                        : Image.asset(
                                                            castItem.profilePath?.startsWith('assets/') == true
                                                                ? castItem.profilePath!
                                                                : 'assets/images/actor_1.jpg',
                                                            width: 68,
                                                            height: 68,
                                                            fit: BoxFit.cover,
                                                          ),
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  castItem.name,
                                                  textAlign: TextAlign.center,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: isDark ? Colors.white : AppColors.lightTextPrimary,
                                                  ),
                                                ),
                                                Text(
                                                  castItem.character,
                                                  textAlign: TextAlign.center,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: isDark ? Colors.white54 : AppColors.lightTextMuted,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  }

                                  return ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: currentMovie.cast.isNotEmpty
                                        ? currentMovie.cast.length
                                        : 2,
                                    itemBuilder: (context, index) {
                                      final castItem = currentMovie.cast.isNotEmpty
                                          ? currentMovie.cast[index]
                                          : MovieCastMember(
                                              actorId: index == 0 ? 101 : 102,
                                              characterName: index == 0 ? 'Nam chính' : 'Nữ chính',
                                            );
                                      final actor = HomeController.instance.getActorById(castItem.actorId);
                                      final actorName = actor?.name ?? (index == 0 ? 'Timothée Chalamet' : 'Zendaya');
                                      final profileImage = actor?.profilePath ?? (index == 0 ? 'assets/images/actor_1.jpg' : 'assets/images/actor_2.jpg');

                                      return GestureDetector(
                                        onTap: () {
                                          context.push(RoutePath.actorPath(castItem.actorId));
                                        },
                                        child: Container(
                                          width: 85,
                                          margin: const EdgeInsets.only(right: 14),
                                          child: Column(
                                            children: [
                                              CircleAvatar(
                                                radius: 34,
                                                backgroundColor: AppColors.darkSurfaceVariant,
                                                backgroundImage: AssetImage(profileImage),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                actorName,
                                                textAlign: TextAlign.center,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: isDark ? Colors.white : AppColors.lightTextPrimary,
                                                ),
                                              ),
                                              Text(
                                                castItem.characterName,
                                                textAlign: TextAlign.center,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: isDark ? Colors.white54 : AppColors.lightTextMuted,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),

                            if (similarMoviesList.isNotEmpty)
                              MovieSectionWidget(
                                title: locale.translate('similar_movies'),
                                movies: similarMoviesList,
                              ),





                            const SizedBox(height: 24),
                            ReviewListWidget(movieId: currentMovie.id),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    ),
  );
}

  Widget _buildFallbackBackdrop(Movie movie) {
    final assetPath = movie.hinhAnh.startsWith('assets/')
        ? movie.hinhAnh
        : ImageUrlHelper.getLocalFallbackImage(movie.id);
    return Image.asset(
      assetPath,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: AppColors.darkSurfaceVariant,
        child: const Center(
          child: Icon(
            Icons.movie_outlined,
            color: Colors.white38,
            size: 64,
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackPoster(Movie movie) {
    final assetPath = movie.hinhAnh.startsWith('assets/')
        ? movie.hinhAnh
        : ImageUrlHelper.getLocalFallbackImage(movie.id);
    return Image.asset(
      assetPath,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: AppColors.darkSurfaceVariant,
        child: const Center(
          child: Icon(
            Icons.local_movies_outlined,
            color: Colors.white38,
            size: 32,
          ),
        ),
      ),
    );
  }
}