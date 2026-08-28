import 'package:equatable/equatable.dart';

import '../../models/movie.dart';
import '../../features/home/domain/entities/cast.dart';
import '../../features/home/domain/entities/video.dart';

// ─── Events ────────────────────────────────────────────────────────────────

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

// ─── States ────────────────────────────────────────────────────────────────

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
  List<Object?> get props =>
      [movie, castList, trailers, similarMovies, isWatchlisted];
}

class MovieDetailErrorState extends MovieDetailState {
  final String message;
  final Movie? initialMovie;

  const MovieDetailErrorState(this.message, {this.initialMovie});

  @override
  List<Object?> get props => [message, initialMovie];
}
