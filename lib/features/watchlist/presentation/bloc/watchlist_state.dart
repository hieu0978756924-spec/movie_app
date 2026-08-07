import 'package:equatable/equatable.dart';
import '../../domain/entities/watchlist_item.dart';

abstract class WatchlistState extends Equatable {
  const WatchlistState();

  @override
  List<Object?> get props => [];
}

class WatchlistInitialState extends WatchlistState {
  const WatchlistInitialState();
}

class WatchlistLoadingState extends WatchlistState {
  const WatchlistLoadingState();
}

class WatchlistLoadedState extends WatchlistState {
  final List<WatchlistItem> items;
  final WatchlistItem? lastRemovedItem;
  final String? message;

  const WatchlistLoadedState({
    required this.items,
    this.lastRemovedItem,
    this.message,
  });

  WatchlistLoadedState copyWith({
    List<WatchlistItem>? items,
    WatchlistItem? lastRemovedItem,
    String? message,
  }) {
    return WatchlistLoadedState(
      items: items ?? this.items,
      lastRemovedItem: lastRemovedItem ?? this.lastRemovedItem,
      message: message,
    );
  }

  @override
  List<Object?> get props => [items, lastRemovedItem, message];
}

class WatchlistErrorState extends WatchlistState {
  final String message;

  const WatchlistErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
