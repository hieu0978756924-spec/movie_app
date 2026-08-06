import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/cast.dart';
import '../../domain/entities/video.dart';
import '../../domain/usecases/get_movie_credits_usecase.dart';
import '../../domain/usecases/get_movie_detail_usecase.dart';
import '../../domain/usecases/get_movie_trailers_usecase.dart';
import '../../domain/usecases/get_similar_movies_usecase.dart';
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

  const MovieDetailLoadedState(
    this.movie, {
    this.castList = const [],
    this.trailers = const [],
    this.similarMovies = const [],
  });

  MovieDetailLoadedState copyWith({
    Movie? movie,
    List<Cast>? castList,
    List<Video>? trailers,
    List<Movie>? similarMovies,
  }) {
    return MovieDetailLoadedState(
      movie ?? this.movie,
      castList: castList ?? this.castList,
      trailers: trailers ?? this.trailers,
      similarMovies: similarMovies ?? this.similarMovies,
    );
  }

  @override
  List<Object?> get props => [movie, castList, trailers, similarMovies];
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

  MovieDetailBloc(
    this.getMovieDetailUseCase,
    this.getMovieCreditsUseCase,
    this.getMovieTrailersUseCase,
    this.getSimilarMoviesUseCase,
  ) : super(MovieDetailInitialState()) {
    on<FetchMovieDetailEvent>(_onFetchMovieDetail);
    on<ToggleFavoriteMovieEvent>(_onToggleFavorite);
  }

  Future<void> _onFetchMovieDetail(
      FetchMovieDetailEvent event, Emitter<MovieDetailState> emit) async {
    emit(MovieDetailLoadingState(initialMovie: event.initialMovie));

    if (event.movieId == 0 && event.initialMovie != null) {
      emit(MovieDetailLoadedState(event.initialMovie!));
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

    detailResult.fold(
      (failure) {},
      (fetchedMovie) => movie = fetchedMovie,
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

    if (movie.tenPhim.isNotEmpty || event.initialMovie != null) {
      emit(MovieDetailLoadedState(
        movie,
        castList: castList,
        trailers: trailers,
        similarMovies: similarMovies,
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
      final updatedMovie =
          currentState.movie.copyWith(yeuThich: !currentState.movie.yeuThich);
      emit(currentState.copyWith(movie: updatedMovie));
    }
  }
}

