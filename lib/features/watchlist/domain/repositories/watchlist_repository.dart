import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/watchlist_item.dart';
import '../../../home/models/movie.dart';

abstract class WatchlistRepository {
  Future<Either<Failure, List<WatchlistItem>>> getWatchlist();
  Future<Either<Failure, void>> addToWatchlist(Movie movie);
  Future<Either<Failure, void>> addWatchlistItem(WatchlistItem item);
  Future<Either<Failure, void>> removeFromWatchlist(int movieId);
  Future<Either<Failure, void>> toggleWatched(int movieId, bool daXem);
  Future<Either<Failure, bool>> isWatchlisted(int movieId);
}
