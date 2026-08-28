import 'package:equatable/equatable.dart';

// ─── Events ────────────────────────────────────────────────────────────────

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
