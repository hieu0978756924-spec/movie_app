import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../home/domain/entities/genre.dart';
import '../../../home/models/movie.dart';
import '../../domain/entities/movie_filter.dart';
import '../../domain/usecases/discover_movies_usecase.dart';
import '../../domain/usecases/get_genres_usecase.dart';
import '../../domain/usecases/search_movies_usecase.dart';
import 'search_event.dart';
import 'search_state.dart';

EventTransformer<Event> debounce<Event>(Duration duration) {
  return (events, mapper) {
    final debouncedEvents = StreamController<Event>();
    Timer? timer;

    final subscription = events.listen(
      (event) {
        timer?.cancel();
        timer = Timer(duration, () {
          if (!debouncedEvents.isClosed) {
            debouncedEvents.add(event);
          }
        });
      },
      onError: debouncedEvents.addError,
      onDone: () {
        timer?.cancel();
        if (!debouncedEvents.isClosed) {
          debouncedEvents.close();
        }
      },
    );

    debouncedEvents.onCancel = () {
      subscription.cancel();
    };

    return debouncedEvents.stream.asyncExpand(mapper);
  };
}

@injectable
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchMoviesUseCase searchMoviesUseCase;
  final GetGenresUseCase getGenresUseCase;
  final DiscoverMoviesUseCase discoverMoviesUseCase;

  String _currentQuery = '';
  MovieFilter _currentFilter = const MovieFilter();
  List<Genre> _genres = const [];

  SearchBloc(
    this.searchMoviesUseCase,
    this.getGenresUseCase,
    this.discoverMoviesUseCase,
  ) : super(const SearchInitialState()) {
    on<FetchGenresEvent>(_onFetchGenres);
    on<SearchQueryChangedEvent>(
      _onSearchQueryChanged,
      transformer: debounce(const Duration(milliseconds: 500)),
    );
    on<ApplyFilterEvent>(_onApplyFilter);
    on<ResetFilterEvent>(_onResetFilter);
    on<ClearSearchEvent>(_onClearSearch);
  }

  Future<void> _onFetchGenres(
    FetchGenresEvent event,
    Emitter<SearchState> emit,
  ) async {
    final result = await getGenresUseCase();
    result.fold(
      (failure) {},
      (genresList) {
        _genres = genresList;
        _emitStateWithContext(emit, state);
      },
    );
  }

  Future<void> _onSearchQueryChanged(
    SearchQueryChangedEvent event,
    Emitter<SearchState> emit,
  ) async {
    _currentQuery = event.query.trim();
    await _performSearchOrDiscover(emit);
  }

  Future<void> _onApplyFilter(
    ApplyFilterEvent event,
    Emitter<SearchState> emit,
  ) async {
    _currentFilter = event.filter;
    await _performSearchOrDiscover(emit);
  }

  Future<void> _onResetFilter(
    ResetFilterEvent event,
    Emitter<SearchState> emit,
  ) async {
    _currentFilter = const MovieFilter();
    await _performSearchOrDiscover(emit);
  }

  Future<void> _onClearSearch(
    ClearSearchEvent event,
    Emitter<SearchState> emit,
  ) async {
    _currentQuery = '';
    await _performSearchOrDiscover(emit);
  }

  Future<void> _performSearchOrDiscover(Emitter<SearchState> emit) async {
    if (_currentQuery.isEmpty && _currentFilter.isDefault) {
      emit(SearchInitialState(filter: _currentFilter, genres: _genres));
      return;
    }

    emit(SearchLoadingState(filter: _currentFilter, genres: _genres));

    if (_currentQuery.isNotEmpty) {
      final result = await searchMoviesUseCase(query: _currentQuery);
      result.fold(
        (failure) => emit(SearchErrorState(
          message: failure.message,
          filter: _currentFilter,
          genres: _genres,
        )),
        (movies) {
          final filteredMovies = _applyLocalFilter(movies);
          if (filteredMovies.isEmpty) {
            emit(SearchEmptyState(
              query: _currentQuery,
              filter: _currentFilter,
              genres: _genres,
            ));
          } else {
            emit(SearchLoadedState(
              movies: filteredMovies,
              query: _currentQuery,
              filter: _currentFilter,
              genres: _genres,
            ));
          }
        },
      );
    } else {
      final result = await discoverMoviesUseCase(filter: _currentFilter);
      result.fold(
        (failure) => emit(SearchErrorState(
          message: failure.message,
          filter: _currentFilter,
          genres: _genres,
        )),
        (movies) {
          if (movies.isEmpty) {
            emit(SearchEmptyState(
              query: '',
              filter: _currentFilter,
              genres: _genres,
            ));
          } else {
            emit(SearchLoadedState(
              movies: movies,
              query: '',
              filter: _currentFilter,
              genres: _genres,
            ));
          }
        },
      );
    }
  }

  List<Movie> _applyLocalFilter(List<Movie> movies) {
    var result = List<Movie>.from(movies);

    if (_currentFilter.minRating > 0.0) {
      result = result
          .where((m) => m.diemDanhGia >= _currentFilter.minRating)
          .toList();
    }

    switch (_currentFilter.sortBy) {
      case SortOption.ratingDesc:
        result.sort((a, b) => b.diemDanhGia.compareTo(a.diemDanhGia));
        break;
      case SortOption.popularityDesc:
        break;
      case SortOption.releaseDateDesc:
      case SortOption.releaseDateAsc:
        break;
    }

    return result;
  }

  void _emitStateWithContext(
      Emitter<SearchState> emit, SearchState currentState) {
    if (currentState is SearchLoadedState) {
      emit(SearchLoadedState(
        movies: currentState.movies,
        query: currentState.query,
        filter: _currentFilter,
        genres: _genres,
      ));
    } else if (currentState is SearchEmptyState) {
      emit(SearchEmptyState(
        query: currentState.query,
        filter: _currentFilter,
        genres: _genres,
      ));
    } else if (currentState is SearchErrorState) {
      emit(SearchErrorState(
        message: currentState.message,
        filter: _currentFilter,
        genres: _genres,
      ));
    } else if (currentState is SearchLoadingState) {
      emit(SearchLoadingState(filter: _currentFilter, genres: _genres));
    } else {
      emit(SearchInitialState(filter: _currentFilter, genres: _genres));
    }
  }
}
