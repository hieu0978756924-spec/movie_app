import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../core/errors/failure.dart';
import '../../features/home/domain/usecases/get_now_playing_movies_usecase.dart';
import '../../features/home/domain/usecases/get_popular_movies_usecase.dart';
import '../../features/home/domain/usecases/get_top_rated_movies_usecase.dart';
import '../../features/home/domain/usecases/get_trending_movies_usecase.dart';
import '../../features/home/domain/usecases/get_upcoming_movies_usecase.dart';
import '../../models/movie.dart';
import 'categories_event.dart';
import 'categories_state.dart';

export 'categories_event.dart';
export 'categories_state.dart';

@injectable
class CategoriesBloc extends Bloc<CategoryEvent, CategoryState> {
  final GetTrendingMoviesUseCase getTrendingMoviesUseCase;
  final GetNowPlayingMoviesUseCase getNowPlayingMoviesUseCase;
  final GetPopularMoviesUseCase getPopularMoviesUseCase;
  final GetTopRatedMoviesUseCase getTopRatedMoviesUseCase;
  final GetUpcomingMoviesUseCase getUpcomingMoviesUseCase;

  CategoriesBloc(
    this.getTrendingMoviesUseCase,
    this.getNowPlayingMoviesUseCase,
    this.getPopularMoviesUseCase,
    this.getTopRatedMoviesUseCase,
    this.getUpcomingMoviesUseCase,
  ) : super(CategoryInitialState()) {
    on<FetchCategoryMoviesEvent>(_onFetchCategoryMovies);
    on<LoadMoreCategoryMoviesEvent>(_onLoadMoreCategoryMovies);
  }

  Future<void> _onFetchCategoryMovies(
      FetchCategoryMoviesEvent event, Emitter<CategoryState> emit) async {
    emit(CategoryLoadingState());

    final result = await _fetchMoviesForCategory(event.categoryType, 1);
    result.fold(
      (failure) => emit(CategoryErrorState(failure.message)),
      (movies) => emit(
        CategoryLoadedState(
          movies: movies,
          categoryType: event.categoryType,
          currentPage: 1,
          hasReachedMax: movies.isEmpty,
        ),
      ),
    );
  }

  Future<void> _onLoadMoreCategoryMovies(
      LoadMoreCategoryMoviesEvent event, Emitter<CategoryState> emit) async {
    if (state is! CategoryLoadedState) return;
    final currentState = state as CategoryLoadedState;
    if (currentState.hasReachedMax || currentState.isLoadingMore) return;

    emit(currentState.copyWith(isLoadingMore: true));
    final nextPage = currentState.currentPage + 1;

    final result =
        await _fetchMoviesForCategory(currentState.categoryType, nextPage);
    result.fold(
      (failure) => emit(currentState.copyWith(isLoadingMore: false)),
      (newMovies) {
        final existingIds = currentState.movies.map((m) => m.id).toSet();
        final uniqueNewMovies =
            newMovies.where((m) => !existingIds.contains(m.id)).toList();

        if (uniqueNewMovies.isEmpty) {
          emit(currentState.copyWith(
            hasReachedMax: true,
            isLoadingMore: false,
          ));
        } else {
          emit(currentState.copyWith(
            movies: List.of(currentState.movies)..addAll(uniqueNewMovies),
            currentPage: nextPage,
            hasReachedMax: false,
            isLoadingMore: false,
          ));
        }
      },
    );
  }

  Future<Either<Failure, List<Movie>>> _fetchMoviesForCategory(
      String categoryType, int page) {
    switch (categoryType) {
      case 'trending':
        return getTrendingMoviesUseCase(page: page);
      case 'now_playing':
        return getNowPlayingMoviesUseCase(page: page);
      case 'popular':
        return getPopularMoviesUseCase(page: page);
      case 'top_rated':
        return getTopRatedMoviesUseCase(page: page);
      case 'upcoming':
        return getUpcomingMoviesUseCase(page: page);
      default:
        return getPopularMoviesUseCase(page: page);
    }
  }
}
