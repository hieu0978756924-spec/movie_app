import 'package:equatable/equatable.dart';

import '../../../home/models/movie.dart';

abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

class SearchInitialState extends SearchState {
  const SearchInitialState();
}

class SearchLoadingState extends SearchState {
  const SearchLoadingState();
}

class SearchLoadedState extends SearchState {
  final List<Movie> movies;
  final String query;

  const SearchLoadedState({
    required this.movies,
    required this.query,
  });

  @override
  List<Object?> get props => [movies, query];
}

class SearchEmptyState extends SearchState {
  final String query;

  const SearchEmptyState(this.query);

  @override
  List<Object?> get props => [query];
}

class SearchErrorState extends SearchState {
  final String message;

  const SearchErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
