import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/usecases/get_now_playing_movies_usecase.dart';
import '../../domain/usecases/get_popular_movies_usecase.dart';
import '../../domain/usecases/get_top_rated_movies_usecase.dart';
import '../../domain/usecases/get_trending_movies_usecase.dart';
import '../../domain/usecases/get_upcoming_movies_usecase.dart';
import '../../models/movie.dart';

// Events
abstract class CategoryEvent extends Equatable {
  const CategoryEvent();
  @override
  List<Object?> get props => [];
}

class FetchCategoryMoviesEvent extends CategoryEvent {
  final String categoryType;
  const FetchCategoryMoviesEvent(this.categoryType);

  @override
  List<Object?> get props => [categoryType];
}

class LoadMoreCategoryMoviesEvent extends CategoryEvent {}

// States
abstract class CategoryState extends Equatable {
  const CategoryState();
  @override
  List<Object?> get props => [];
}

class CategoryInitialState extends CategoryState {}

class CategoryLoadingState extends CategoryState {}

class CategoryLoadedState extends CategoryState {
  final List<Movie> movies;
  final String categoryType;
  final int currentPage;
  final bool hasReachedMax;
  final bool isLoadingMore;

  const CategoryLoadedState({
    required this.movies,
    required this.categoryType,
    required this.currentPage,
    required this.hasReachedMax,
    this.isLoadingMore = false,
  });

  CategoryLoadedState copyWith({
    List<Movie>? movies,
    String? categoryType,
    int? currentPage,
    bool? hasReachedMax,
    bool? isLoadingMore,
  }) {
    return CategoryLoadedState(
      movies: movies ?? this.movies,
      categoryType: categoryType ?? this.categoryType,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props =>
      [movies, categoryType, currentPage, hasReachedMax, isLoadingMore];
}

class CategoryErrorState extends CategoryState {
  final String message;
  const CategoryErrorState(this.message);

  @override
  List<Object?> get props => [message];
}

@injectable
class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final GetTrendingMoviesUseCase getTrendingMoviesUseCase;
  final GetNowPlayingMoviesUseCase getNowPlayingMoviesUseCase;
  final GetPopularMoviesUseCase getPopularMoviesUseCase;
  final GetTopRatedMoviesUseCase getTopRatedMoviesUseCase;
  final GetUpcomingMoviesUseCase getUpcomingMoviesUseCase;

  CategoryBloc(
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
        if (newMovies.isEmpty) {
          emit(currentState.copyWith(
            hasReachedMax: true,
            isLoadingMore: false,
          ));
        } else {
          emit(currentState.copyWith(
            movies: List.of(currentState.movies)..addAll(newMovies),
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
