import 'package:equatable/equatable.dart';
import '../../../home/models/movie.dart';
import '../../domain/entities/watchlist_item.dart';

abstract class WatchlistEvent extends Equatable {
  const WatchlistEvent();

  @override
  List<Object?> get props => [];
}

class LoadWatchlistEvent extends WatchlistEvent {
  const LoadWatchlistEvent();
}

class AddMovieToWatchlistEvent extends WatchlistEvent {
  final Movie movie;

  const AddMovieToWatchlistEvent(this.movie);

  @override
  List<Object?> get props => [movie];
}

class AddItemToWatchlistEvent extends WatchlistEvent {
  final WatchlistItem item;

  const AddItemToWatchlistEvent(this.item);

  @override
  List<Object?> get props => [item];
}

class RemoveFromWatchlistEvent extends WatchlistEvent {
  final int movieId;

  const RemoveFromWatchlistEvent(this.movieId);

  @override
  List<Object?> get props => [movieId];
}

class ToggleWatchedEvent extends WatchlistEvent {
  final int movieId;
  final bool daXem;

  const ToggleWatchedEvent({required this.movieId, required this.daXem});

  @override
  List<Object?> get props => [movieId, daXem];
}
