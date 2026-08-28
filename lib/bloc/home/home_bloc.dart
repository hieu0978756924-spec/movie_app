import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../features/home/domain/usecases/get_now_playing_movies_usecase.dart';
import '../../features/home/domain/usecases/get_popular_movies_usecase.dart';
import '../../features/home/domain/usecases/get_similar_movies_usecase.dart';
import '../../features/home/domain/usecases/get_top_rated_movies_usecase.dart';
import '../../features/home/domain/usecases/get_trending_movies_usecase.dart';
import '../../features/home/domain/usecases/get_upcoming_movies_usecase.dart';
import '../../features/watchlist/data/datasources/watchlist_local_datasource.dart';
import '../../features/home/controllers/home_controller.dart';
import '../../models/movie.dart';
import 'home_event.dart';
import 'home_state.dart';

export 'home_event.dart';
export 'home_state.dart';

@injectable
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetTrendingMoviesUseCase getTrendingMoviesUseCase;
  final GetNowPlayingMoviesUseCase getNowPlayingMoviesUseCase;
  final GetPopularMoviesUseCase getPopularMoviesUseCase;
  final GetTopRatedMoviesUseCase getTopRatedMoviesUseCase;
  final GetUpcomingMoviesUseCase getUpcomingMoviesUseCase;
  final GetSimilarMoviesUseCase getSimilarMoviesUseCase;
  final WatchlistLocalDataSource watchlistLocalDataSource;

  HomeBloc(
    this.getTrendingMoviesUseCase,
    this.getNowPlayingMoviesUseCase,
    this.getPopularMoviesUseCase,
    this.getTopRatedMoviesUseCase,
    this.getUpcomingMoviesUseCase,
    this.getSimilarMoviesUseCase,
    this.watchlistLocalDataSource,
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
    if (nowPlaying.isEmpty)
      nowPlaying = HomeController.instance.danhSachPhimDangChieu;
    if (popular.isEmpty) popular = HomeController.instance.danhSachPhimPhoBien;
    if (topRated.isEmpty)
      topRated = HomeController.instance.danhSachPhimDanhGiaCao;
    if (upcoming.isEmpty)
      upcoming = HomeController.instance.danhSachPhimSapChieu;

    final nowPlayingIds = nowPlaying.map((m) => m.id).toSet();
    upcoming = upcoming.where((m) => !nowPlayingIds.contains(m.id)).toList();

    List<Movie> recommendedMovies = [];
    String? recommendedSourceTitle;

    try {
      final watchlist = await watchlistLocalDataSource.getWatchlist();
      if (watchlist.isNotEmpty) {
        final latestItem = watchlist.first;
        recommendedSourceTitle = latestItem.tenPhim;
        final recResult = await getSimilarMoviesUseCase(latestItem.id);
        recommendedMovies = recResult.fold((_) => <Movie>[], (movies) => movies);
      }
    } catch (_) {
      // Fallback gracefully if recommendations fail
    }

    emit(
      HomeLoadedState(
        trendingMovies: trending,
        nowPlayingMovies: nowPlaying,
        popularMovies: popular,
        topRatedMovies: topRated,
        upcomingMovies: upcoming,
        recommendedMovies: recommendedMovies,
        recommendedSourceTitle: recommendedSourceTitle,
      ),
    );
  }
}
