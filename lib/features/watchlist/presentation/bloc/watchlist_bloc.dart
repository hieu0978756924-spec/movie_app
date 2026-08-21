import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/watchlist_item.dart';
import '../../domain/repositories/watchlist_repository.dart';
import 'watchlist_event.dart';
import 'watchlist_state.dart';

@injectable
class WatchlistBloc extends Bloc<WatchlistEvent, WatchlistState> {
  final WatchlistRepository watchlistRepository;

  WatchlistBloc(this.watchlistRepository)
      : super(const WatchlistInitialState()) {
    on<LoadWatchlistEvent>(_onLoadWatchlist);
    on<SyncWatchlistEvent>(_onSyncWatchlist);
    on<AddMovieToWatchlistEvent>(_onAddMovieToWatchlist);
    on<AddItemToWatchlistEvent>(_onAddItemToWatchlist);
    on<RemoveFromWatchlistEvent>(_onRemoveFromWatchlist);
    on<ToggleWatchedEvent>(_onToggleWatched);
  }

  Future<void> _onLoadWatchlist(
    LoadWatchlistEvent event,
    Emitter<WatchlistState> emit,
  ) async {
    emit(const WatchlistLoadingState());
    final result = await watchlistRepository.getWatchlist();
    result.fold(
      (failure) => emit(WatchlistErrorState(failure.message)),
      (items) => emit(WatchlistLoadedState(items: items)),
    );
  }

  Future<void> _onSyncWatchlist(
    SyncWatchlistEvent event,
    Emitter<WatchlistState> emit,
  ) async {
    emit(const WatchlistLoadingState());
    final syncResult = await watchlistRepository.syncWatchlist();
    if (syncResult.isLeft()) {
      final failure = syncResult.fold((l) => l, (_) => null)!;
      emit(WatchlistErrorState(failure.message));
      return;
    }
    await _fetchAndEmitWatchlist(emit);
  }

  Future<void> _onAddMovieToWatchlist(
    AddMovieToWatchlistEvent event,
    Emitter<WatchlistState> emit,
  ) async {
    final result = await watchlistRepository.addToWatchlist(event.movie);
    if (result.isLeft()) {
      final failure = result.fold((l) => l, (_) => null)!;
      emit(WatchlistErrorState(failure.message));
    } else {
      await _fetchAndEmitWatchlist(emit);
    }
  }

  Future<void> _onAddItemToWatchlist(
    AddItemToWatchlistEvent event,
    Emitter<WatchlistState> emit,
  ) async {
    final result = await watchlistRepository.addWatchlistItem(event.item);
    if (result.isLeft()) {
      final failure = result.fold((l) => l, (_) => null)!;
      emit(WatchlistErrorState(failure.message));
    } else {
      await _fetchAndEmitWatchlist(emit);
    }
  }

  Future<void> _onRemoveFromWatchlist(
    RemoveFromWatchlistEvent event,
    Emitter<WatchlistState> emit,
  ) async {
    WatchlistItem? removedItem;
    if (state is WatchlistLoadedState) {
      final currentItems = (state as WatchlistLoadedState).items;
      try {
        removedItem =
            currentItems.firstWhere((item) => item.id == event.movieId);
      } catch (_) {}
    }

    final result = await watchlistRepository.removeFromWatchlist(event.movieId);
    if (result.isLeft()) {
      final failure = result.fold((l) => l, (_) => null)!;
      emit(WatchlistErrorState(failure.message));
      return;
    }

    final fetchResult = await watchlistRepository.getWatchlist();
    fetchResult.fold(
      (failure) => emit(WatchlistErrorState(failure.message)),
      (items) => emit(WatchlistLoadedState(
        items: items,
        lastRemovedItem: removedItem,
        message: removedItem != null ? 'Đã xóa "${removedItem.tenPhim}"' : null,
      )),
    );
  }

  Future<void> _onToggleWatched(
    ToggleWatchedEvent event,
    Emitter<WatchlistState> emit,
  ) async {
    final result = await watchlistRepository.toggleWatched(
      event.movieId,
      event.daXem,
    );
    if (result.isLeft()) {
      final failure = result.fold((l) => l, (_) => null)!;
      emit(WatchlistErrorState(failure.message));
    } else {
      await _fetchAndEmitWatchlist(emit);
    }
  }

  Future<void> _fetchAndEmitWatchlist(Emitter<WatchlistState> emit) async {
    final result = await watchlistRepository.getWatchlist();
    result.fold(
      (failure) => emit(WatchlistErrorState(failure.message)),
      (items) => emit(WatchlistLoadedState(items: items)),
    );
  }
}
