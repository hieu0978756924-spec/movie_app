import 'package:equatable/equatable.dart';

import '../../domain/entities/movie_filter.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class SearchQueryChangedEvent extends SearchEvent {
  final String query;

  const SearchQueryChangedEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class ClearSearchEvent extends SearchEvent {
  const ClearSearchEvent();
}

class FetchGenresEvent extends SearchEvent {
  const FetchGenresEvent();
}

class ApplyFilterEvent extends SearchEvent {
  final MovieFilter filter;

  const ApplyFilterEvent(this.filter);

  @override
  List<Object?> get props => [filter];
}

class ResetFilterEvent extends SearchEvent {
  const ResetFilterEvent();
}
