import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/usecases/get_now_playing_movies_usecase.dart';
import '../../domain/usecases/get_popular_movies_usecase.dart';
import '../../domain/usecases/get_top_rated_movies_usecase.dart';
import '../../domain/usecases/get_trending_movies_usecase.dart';
import '../../domain/usecases/get_upcoming_movies_usecase.dart';
import '../../controllers/home_controller.dart';
import '../../models/movie.dart';

// Events
abstract class HomeEvent extends Equatable {
  const HomeEvent();
  @override
  List<Object?> get props => [];
}

class FetchHomeMoviesEvent extends HomeEvent {}

class RefreshHomeMoviesEvent extends HomeEvent {}

// States
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

  const HomeLoadedState({
    required this.trendingMovies,
    required this.nowPlayingMovies,
    required this.popularMovies,
    required this.topRatedMovies,
    required this.upcomingMovies,
  });

  @override
  List<Object?> get props => [
        trendingMovies,
        nowPlayingMovies,
        popularMovies,
        topRatedMovies,
        upcomingMovies,
      ];
}

class HomeErrorState extends HomeState {
  final String message;
  const HomeErrorState(this.message);

  @override
  List<Object?> get props => [message];
}

@injectable
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetTrendingMoviesUseCase getTrendingMoviesUseCase;
  final GetNowPlayingMoviesUseCase getNowPlayingMoviesUseCase;
  final GetPopularMoviesUseCase getPopularMoviesUseCase;
  final GetTopRatedMoviesUseCase getTopRatedMoviesUseCase;
  final GetUpcomingMoviesUseCase getUpcomingMoviesUseCase;

  HomeBloc(
    this.getTrendingMoviesUseCase,
    this.getNowPlayingMoviesUseCase,
    this.getPopularMoviesUseCase,
    this.getTopRatedMoviesUseCase,
    this.getUpcomingMoviesUseCase,
  ) : super(HomeInitialState()) {
    on<FetchHomeMoviesEvent>(_onFetchHomeMovies);
    on<RefreshHomeMoviesEvent>(_onRefreshHomeMovies);
  }

  Future<void> _onFetchHomeMovies(
      FetchHomeMoviesEvent event, Emitter<HomeState> emit) async {
    emit(HomeLoadingState());
    await _loadMovies(emit);
  }

  Future<void> _onRefreshHomeMovies(
      RefreshHomeMoviesEvent event, Emitter<HomeState> emit) async {
    await _loadMovies(emit);
  }

  Future<void> _loadMovies(Emitter<HomeState> emit) async {
    await HomeController.instance.init();

    final results = await Future.wait([
      getTrendingMoviesUseCase(),
      getNowPlayingMoviesUseCase(),
      getPopularMoviesUseCase(),
      getTopRatedMoviesUseCase(),
      getUpcomingMoviesUseCase(),
    ]);

    final trendingResult = results[0];
    final nowPlayingResult = results[1];
    final popularResult = results[2];
    final topRatedResult = results[3];
    final upcomingResult = results[4];

    var trending = trendingResult.fold((_) => <Movie>[], (movies) => movies);
    var nowPlaying = nowPlayingResult.fold((_) => <Movie>[], (movies) => movies);
    var popular = popularResult.fold((_) => <Movie>[], (movies) => movies);
    var topRated = topRatedResult.fold((_) => <Movie>[], (movies) => movies);
    var upcoming = upcomingResult.fold((_) => <Movie>[], (movies) => movies);

    if (trending.isEmpty) trending = HomeController.instance.danhSachPhimHot;
    if (nowPlaying.isEmpty) nowPlaying = HomeController.instance.danhSachPhimDangChieu;
    if (popular.isEmpty) popular = HomeController.instance.danhSachPhimPhoBien;
    if (topRated.isEmpty) topRated = HomeController.instance.danhSachPhimDanhGiaCao;
    if (upcoming.isEmpty) upcoming = HomeController.instance.danhSachPhimSapChieu;

    emit(
      HomeLoadedState(
        trendingMovies: trending,
        nowPlayingMovies: nowPlaying,
        popularMovies: popular,
        topRatedMovies: topRated,
        upcomingMovies: upcoming,
      ),
    );
  }
}
