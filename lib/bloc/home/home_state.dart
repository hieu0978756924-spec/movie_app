import 'package:equatable/equatable.dart';

import '../../models/movie.dart';

// ─── States ────────────────────────────────────────────────────────────────

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitialState extends HomeState {}

class HomeLoadingState extends HomeState {}

class HomeLoadedState extends HomeState {
  final List<Movie> trendingMovies;
  final List<Movie> nowPlayingMovies;
  final List<Movie> popularMovies;
  final List<Movie> topRatedMovies;
  final List<Movie> upcomingMovies;
  final List<Movie> recommendedMovies;
  final String? recommendedSourceTitle;

  const HomeLoadedState({
    required this.trendingMovies,
    required this.nowPlayingMovies,
    required this.popularMovies,
    required this.topRatedMovies,
    required this.upcomingMovies,
    this.recommendedMovies = const [],
    this.recommendedSourceTitle,
  });

  @override
  List<Object?> get props => [
        trendingMovies,
        nowPlayingMovies,
        popularMovies,
        topRatedMovies,
        upcomingMovies,
        recommendedMovies,
        recommendedSourceTitle,
      ];
}

class HomeErrorState extends HomeState {
  final String message;

  const HomeErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
