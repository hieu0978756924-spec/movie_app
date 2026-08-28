import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../core/di/injection.dart';
import '../../core/errors/failure.dart';
import '../../core/utils/youtube_utils.dart';
import '../../features/watchlist/domain/repositories/watchlist_repository.dart';
import '../../features/watchlist/presentation/bloc/watchlist_bloc.dart';
import '../../features/watchlist/presentation/bloc/watchlist_event.dart';
import '../../features/home/domain/entities/cast.dart';
import '../../features/home/domain/entities/video.dart';
import '../../features/home/domain/usecases/get_movie_credits_usecase.dart';
import '../../features/home/domain/usecases/get_movie_detail_usecase.dart';
import '../../features/home/domain/usecases/get_movie_trailers_usecase.dart';
import '../../features/home/domain/usecases/get_similar_movies_usecase.dart';
import '../../features/home/controllers/home_controller.dart';
import '../../models/movie.dart';
import 'movie_detail_bundle.dart';

export 'movie_detail_bundle.dart';

@injectable
class MovieDetailBloc extends Bloc<MovieDetailEvent, MovieDetailState> {
  final GetMovieDetailUseCase getMovieDetailUseCase;
  final GetMovieCreditsUseCase getMovieCreditsUseCase;
  final GetMovieTrailersUseCase getMovieTrailersUseCase;
  final GetSimilarMoviesUseCase getSimilarMoviesUseCase;
  final WatchlistRepository watchlistRepository;

  MovieDetailBloc(
    this.getMovieDetailUseCase,
    this.getMovieCreditsUseCase,
    this.getMovieTrailersUseCase,
    this.getSimilarMoviesUseCase,
    this.watchlistRepository,
  ) : super(MovieDetailInitialState()) {
    on<FetchMovieDetailEvent>(_onFetchMovieDetail);
    on<ToggleFavoriteMovieEvent>(_onToggleFavorite);
    on<ToggleWatchlistMovieEvent>(_onToggleWatchlist);
  }

  Future<void> _onFetchMovieDetail(
      FetchMovieDetailEvent event, Emitter<MovieDetailState> emit) async {
    emit(MovieDetailLoadingState(initialMovie: event.initialMovie));

    final targetId =
        event.movieId != 0 ? event.movieId : (event.initialMovie?.id ?? 0);

    if (targetId == 0) {
      if (event.initialMovie != null) {
        emit(MovieDetailLoadedState(event.initialMovie!));
      } else {
        emit(MovieDetailErrorState(
          'Lỗi lấy chi tiết phim',
          initialMovie: event.initialMovie,
        ));
      }
      return;
    }

    final results = await Future.wait([
      getMovieDetailUseCase(targetId),
      getMovieCreditsUseCase(targetId),
      getMovieTrailersUseCase(targetId),
      getSimilarMoviesUseCase(targetId),
    ]);

    final detailResult = results[0] as Either<Failure, Movie>;
    final creditsResult = results[1] as Either<Failure, List<Cast>>;
    final trailersResult = results[2] as Either<Failure, List<Video>>;
    final similarResult = results[3] as Either<Failure, List<Movie>>;

    Movie movie = event.initialMovie ??
        Movie(
          id: targetId,
          tenPhim: '',
          hinhAnh: '',
          moTa: '',
          diemDanhGia: 0,
        );

    bool initialFav = event.initialMovie?.yeuThich ?? false;
    if (targetId != 0) {
      final existingIndex = HomeController.instance.danhSachPhim
          .indexWhere((m) => m.id == targetId);
      if (existingIndex != -1) {
        initialFav =
            HomeController.instance.danhSachPhim[existingIndex].yeuThich;
      }
    }

    detailResult.fold(
      (failure) {
        if (event.initialMovie != null) {
          movie = event.initialMovie!.copyWith(yeuThich: initialFav);
        }
      },
      (fetchedMovie) {
        if (event.initialMovie != null &&
            event.initialMovie!.tenPhim.isNotEmpty &&
            fetchedMovie.tenPhim.isEmpty) {
          movie = event.initialMovie!.copyWith(yeuThich: initialFav);
        } else {
          movie = fetchedMovie.copyWith(yeuThich: initialFav);
        }
      },
    );

    List<Cast> castList = [];
    creditsResult.fold(
      (failure) {},
      (fetchedCast) => castList = fetchedCast,
    );

    List<Video> trailers = [];
    trailersResult.fold(
      (failure) {},
      (fetchedTrailers) {
        trailers = fetchedTrailers;
        if (trailers.isNotEmpty) {
          final officialTrailer = trailers.firstWhere(
            (v) =>
                v.site.toLowerCase() == 'youtube' &&
                v.type.toLowerCase() == 'trailer' &&
                (v.official == true || v.name.toLowerCase().contains('official')),
            orElse: () => trailers.firstWhere(
              (v) =>
                  v.site.toLowerCase() == 'youtube' &&
                  (v.type.toLowerCase() == 'trailer' ||
                      v.type.toLowerCase() == 'teaser'),
              orElse: () => trailers.firstWhere(
                (v) => v.site.toLowerCase() == 'youtube',
                orElse: () => trailers.first,
              ),
            ),
          );
          final key = YoutubeUtils.extractYoutubeKey(officialTrailer.key);
          if (key.isNotEmpty) {
            movie = movie.copyWith(
                trailerUrl: 'https://www.youtube.com/watch?v=$key');
          }
        }
      },
    );

    List<Movie> similarMovies = [];
    similarResult.fold(
      (failure) {},
      (fetchedSimilar) => similarMovies = fetchedSimilar,
    );

    bool isWatchlisted = false;
    if (targetId != 0) {
      try {
        final res = await watchlistRepository.isWatchlisted(targetId);
        res.fold((l) {}, (r) => isWatchlisted = r);
      } catch (_) {}
    }

    if (movie.tenPhim.isNotEmpty || event.initialMovie != null) {
      emit(MovieDetailLoadedState(
        movie,
        castList: castList,
        trailers: trailers,
        similarMovies: similarMovies,
        isWatchlisted: isWatchlisted,
      ));
    } else {
      emit(MovieDetailErrorState(
        'Lỗi lấy chi tiết phim',
        initialMovie: event.initialMovie,
      ));
    }
  }

  void _onToggleFavorite(
      ToggleFavoriteMovieEvent event, Emitter<MovieDetailState> emit) {
    if (state is MovieDetailLoadedState) {
      final currentState = state as MovieDetailLoadedState;
      final newFav = !currentState.movie.yeuThich;
      final updatedMovie = currentState.movie.copyWith(yeuThich: newFav);
      HomeController.instance.capNhatTrangThaiYeuThich(updatedMovie, newFav);
      emit(currentState.copyWith(movie: updatedMovie));
    } else if (state is MovieDetailLoadingState) {
      final currentState = state as MovieDetailLoadingState;
      if (currentState.initialMovie != null) {
        final newFav = !currentState.initialMovie!.yeuThich;
        final updatedMovie =
            currentState.initialMovie!.copyWith(yeuThich: newFav);
        HomeController.instance.capNhatTrangThaiYeuThich(updatedMovie, newFav);
        emit(MovieDetailLoadingState(initialMovie: updatedMovie));
      }
    }
  }

  Future<void> _onToggleWatchlist(
      ToggleWatchlistMovieEvent event, Emitter<MovieDetailState> emit) async {
    if (state is MovieDetailLoadedState) {
      final currentState = state as MovieDetailLoadedState;
      final newStatus = !currentState.isWatchlisted;
      emit(currentState.copyWith(isWatchlisted: newStatus));

      try {
        if (newStatus) {
          await watchlistRepository.addToWatchlist(currentState.movie);
        } else {
          await watchlistRepository.removeFromWatchlist(currentState.movie.id);
        }
      } catch (_) {}

      try {
        if (newStatus) {
          getIt<WatchlistBloc>().add(AddMovieToWatchlistEvent(currentState.movie));
        } else {
          getIt<WatchlistBloc>()
              .add(RemoveFromWatchlistEvent(currentState.movie.id));
        }
      } catch (_) {}
    }
  }
}
