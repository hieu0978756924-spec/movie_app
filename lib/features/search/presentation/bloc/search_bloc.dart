import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

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

  SearchBloc(this.searchMoviesUseCase) : super(const SearchInitialState()) {
    on<SearchQueryChangedEvent>(
      _onSearchQueryChanged,
      transformer: debounce(const Duration(milliseconds: 500)),
    );

    on<ClearSearchEvent>(_onClearSearch);
  }

  Future<void> _onSearchQueryChanged(
    SearchQueryChangedEvent event,
    Emitter<SearchState> emit,
  ) async {
    final trimmedQuery = event.query.trim();
    if (trimmedQuery.isEmpty) {
      emit(const SearchInitialState());
      return;
    }

    emit(const SearchLoadingState());

    final result = await searchMoviesUseCase(query: trimmedQuery);
    result.fold(
      (failure) => emit(SearchErrorState(failure.message)),
      (movies) {
        if (movies.isEmpty) {
          emit(SearchEmptyState(trimmedQuery));
        } else {
          emit(SearchLoadedState(movies: movies, query: trimmedQuery));
        }
      },
    );
  }

  void _onClearSearch(
    ClearSearchEvent event,
    Emitter<SearchState> emit,
  ) {
    emit(const SearchInitialState());
  }
}
