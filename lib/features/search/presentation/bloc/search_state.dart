import 'package:equatable/equatable.dart';

import '../../../home/domain/entities/genre.dart';
import '../../../home/models/movie.dart';
import '../../domain/entities/movie_filter.dart';

abstract class SearchState extends Equatable {
  final MovieFilter filter;
  final List<Genre> genres;

  const SearchState({
    this.filter = const MovieFilter(),
    this.genres = const [],
  });

  @override
  List<Object?> get props => [filter, genres];
}

class SearchInitialState extends SearchState {
  const SearchInitialState({
    super.filter = const MovieFilter(),
    super.genres = const [],
  });
}

class SearchLoadingState extends SearchState {
  const SearchLoadingState({
    super.filter = const MovieFilter(),
    super.genres = const [],
  });
}

class SearchLoadedState extends SearchState {
  final List<Movie> movies;
  final String query;

  const SearchLoadedState({
    required this.movies,
    required this.query,
    super.filter = const MovieFilter(),
    super.genres = const [],
  });

  @override
  List<Object?> get props => [movies, query, filter, genres];
}

class SearchEmptyState extends SearchState {
  final String query;

  const SearchEmptyState({
    required this.query,
    super.filter = const MovieFilter(),
    super.genres = const [],
  });

  @override
  List<Object?> get props => [query, filter, genres];
}

class SearchErrorState extends SearchState {
  final String message;

  const SearchErrorState({
    required this.message,
    super.filter = const MovieFilter(),
    super.genres = const [],
  });

  @override
  List<Object?> get props => [message, filter, genres];
}
