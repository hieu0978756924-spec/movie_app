import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failure.dart';
import '../../../home/models/movie.dart';
import '../../domain/entities/watchlist_item.dart';
import '../../domain/repositories/watchlist_repository.dart';
import '../datasources/watchlist_local_datasource.dart';
import '../models/watchlist_item_model.dart';

@LazySingleton(as: WatchlistRepository)
class WatchlistRepositoryImpl implements WatchlistRepository {
  final WatchlistLocalDataSource localDataSource;

  WatchlistRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, List<WatchlistItem>>> getWatchlist() async {
    try {
      final models = await localDataSource.getWatchlist();
      final entities = models.map((m) => m.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addToWatchlist(Movie movie) async {
    try {
      final model = WatchlistItemModel.fromMovie(movie);
      await localDataSource.addToWatchlist(model);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addWatchlistItem(WatchlistItem item) async {
    try {
      final model = WatchlistItemModel.fromEntity(item);
      await localDataSource.addToWatchlist(model);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeFromWatchlist(int movieId) async {
    try {
      await localDataSource.removeFromWatchlist(movieId);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleWatched(int movieId, bool daXem) async {
    try {
      await localDataSource.toggleWatched(movieId, daXem);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isWatchlisted(int movieId) async {
    try {
      final result = await localDataSource.isWatchlisted(movieId);
      return Right(result);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
