import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/errors/failure.dart';
import '../../../watchlist/domain/repositories/watchlist_repository.dart';
import '../../../watchlist/presentation/bloc/watchlist_bloc.dart';
import '../../../watchlist/presentation/bloc/watchlist_event.dart';
import '../../domain/entities/cast.dart';
import '../../domain/entities/video.dart';
import '../../domain/usecases/get_movie_credits_usecase.dart';
import '../../domain/usecases/get_movie_detail_usecase.dart';
import '../../domain/usecases/get_movie_trailers_usecase.dart';
import '../../domain/usecases/get_similar_movies_usecase.dart';
import '../../controllers/home_controller.dart';
import '../../models/movie.dart';

// Events
abstract class MovieDetailEvent extends Equatable {
  const MovieDetailEvent();
  @override
  List<Object?> get props => [];
}

class FetchMovieDetailEvent extends MovieDetailEvent {
  final int movieId;
  final Movie? initialMovie;

  const FetchMovieDetailEvent(this.movieId, {this.initialMovie});

  @override
  List<Object?> get props => [movieId, initialMovie];
}

class ToggleFavoriteMovieEvent extends MovieDetailEvent {}
class ToggleWatchlistMovieEvent extends MovieDetailEvent {}

// States
abstract class MovieDetailState extends Equatable {
  const MovieDetailState();
  @override
  List<Object?> get props => [];
}

class MovieDetailInitialState extends MovieDetailState {}

class MovieDetailLoadingState extends MovieDetailState {
  final Movie? initialMovie;
  const MovieDetailLoadingState({this.initialMovie});

  @override
  List<Object?> get props => [initialMovie];
}

class MovieDetailLoadedState extends MovieDetailState {
  final Movie movie;
  final List<Cast> castList;
  final List<Video> trailers;
  final List<Movie> similarMovies;
  final bool isWatchlisted;

  const MovieDetailLoadedState(
    this.movie, {
    this.castList = const [],
    this.trailers = const [],
    this.similarMovies = const [],
    this.isWatchlisted = false,
  });

  MovieDetailLoadedState copyWith({
    Movie? movie,
    List<Cast>? castList,
    List<Video>? trailers,
    List<Movie>? similarMovies,
    bool? isWatchlisted,
  }) {
    return MovieDetailLoadedState(
      movie ?? this.movie,
      castList: castList ?? this.castList,
      trailers: trailers ?? this.trailers,
      similarMovies: similarMovies ?? this.similarMovies,
      isWatchlisted: isWatchlisted ?? this.isWatchlisted,
    );
  }

  @override
  List<Object?> get props => [movie, castList, trailers, similarMovies, isWatchlisted];
}

class MovieDetailErrorState extends MovieDetailState {
  final String message;
  final Movie? initialMovie;

  const MovieDetailErrorState(this.message, {this.initialMovie});

  @override
  List<Object?> get props => [message, initialMovie];
}

@injectable
class MovieDetailBloc extends Bloc<MovieDetailEvent, MovieDetailState> {
  final GetMovieDetailUseCase getMovieDetailUseCase;
  final GetMovieCreditsUseCase getMovieCreditsUseCase;
  final GetMovieTrailersUseCase getMovieTrailersUseCase;
  final GetSimilarMoviesUseCase getSimilarMoviesUseCase;
  final WatchlistRepository? watchlistRepository;

  MovieDetailBloc(
    this.getMovieDetailUseCase,
    this.getMovieCreditsUseCase,
    this.getMovieTrailersUseCase,
    this.getSimilarMoviesUseCase, {
    this.watchlistRepository,
  }) : super(MovieDetailInitialState()) {
    on<FetchMovieDetailEvent>(_onFetchMovieDetail);
    on<ToggleFavoriteMovieEvent>(_onToggleFavorite);
    on<ToggleWatchlistMovieEvent>(_onToggleWatchlist);
  }

  Future<void> _onFetchMovieDetail(
      FetchMovieDetailEvent event, Emitter<MovieDetailState> emit) async {
    emit(MovieDetailLoadingState(initialMovie: event.initialMovie));

    if (event.movieId == 0 && event.initialMovie != null) {
      bool isWatchlisted = false;
      if (watchlistRepository != null) {
        try {
          final res = await watchlistRepository!.isWatchlisted(event.initialMovie!.id);
          res.fold((l) {}, (r) => isWatchlisted = r);
        } catch (_) {}
      }

      emit(MovieDetailLoadedState(
        event.initialMovie!,
        isWatchlisted: isWatchlisted,
      ));
      return;
    }

    final detailFuture = getMovieDetailUseCase(event.movieId);
    final creditsFuture = getMovieCreditsUseCase(event.movieId);
    final trailersFuture = getMovieTrailersUseCase(event.movieId);
    final similarFuture = getSimilarMoviesUseCase(event.movieId);

    final results = await Future.wait([
      detailFuture,
      creditsFuture,
      trailersFuture,
      similarFuture,
    ]);

    final detailResult = results[0] as Either<Failure, Movie>;
    final creditsResult = results[1] as Either<Failure, List<Cast>>;
    final trailersResult = results[2] as Either<Failure, List<Video>>;
    final similarResult = results[3] as Either<Failure, List<Movie>>;

    Movie movie = event.initialMovie ??
        Movie(
          id: event.movieId,
          tenPhim: '',
          hinhAnh: '',
          moTa: '',
          diemDanhGia: 0,
        );

    final targetId = event.movieId != 0 ? event.movieId : (event.initialMovie?.id ?? 0);
    bool initialFav = event.initialMovie?.yeuThich ?? false;
    if (targetId != 0) {
      final existingIndex = HomeController.instance.danhSachPhim.indexWhere((m) => m.id == targetId);
      if (existingIndex != -1) {
        initialFav = HomeController.instance.danhSachPhim[existingIndex].yeuThich;
      }
    }

    detailResult.fold(
      (failure) {
        if (event.initialMovie != null) {
          movie = event.initialMovie!.copyWith(yeuThich: initialFav);
        }
      },
      (fetchedMovie) {
        movie = fetchedMovie.copyWith(yeuThich: initialFav);
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
      (fetchedTrailers) => trailers = fetchedTrailers,
    );

    List<Movie> similarMovies = [];
    similarResult.fold(
      (failure) {},
      (fetchedSimilar) => similarMovies = fetchedSimilar,
    );

    bool isWatchlisted = false;
    if (targetId != 0 && watchlistRepository != null) {
      try {
        final res = await watchlistRepository!.isWatchlisted(targetId);
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
        final updatedMovie = currentState.initialMovie!.copyWith(yeuThich: newFav);
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

      if (watchlistRepository != null) {
        try {
          if (newStatus) {
            await watchlistRepository!.addToWatchlist(currentState.movie);
          } else {
            await watchlistRepository!.removeFromWatchlist(currentState.movie.id);
          }
        } catch (_) {}
      }

      try {
        if (newStatus) {
          getIt<WatchlistBloc>().add(AddMovieToWatchlistEvent(currentState.movie));
        } else {
          getIt<WatchlistBloc>().add(RemoveFromWatchlistEvent(currentState.movie.id));
        }
      } catch (_) {}
    }
  }
}

