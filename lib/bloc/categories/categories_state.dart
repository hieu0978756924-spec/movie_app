import 'package:equatable/equatable.dart';

import '../../models/movie.dart';

// ─── States ────────────────────────────────────────────────────────────────

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
