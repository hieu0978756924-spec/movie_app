import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/failure.dart';
import '../../../home/models/movie.dart';
import '../../domain/entities/watchlist_item.dart';
import '../../domain/repositories/watchlist_repository.dart';
import '../datasources/watchlist_local_datasource.dart';
import '../datasources/watchlist_remote_datasource.dart';
import '../models/watchlist_item_model.dart';

@LazySingleton(as: WatchlistRepository)
class WatchlistRepositoryImpl implements WatchlistRepository {
  final WatchlistLocalDataSource localDataSource;
  final WatchlistRemoteDataSource remoteDataSource;
  final SupabaseClient supabaseClient;

  WatchlistRepositoryImpl(
    this.localDataSource,
    this.remoteDataSource,
    this.supabaseClient,
  );

  String? get _currentUserId => supabaseClient.auth.currentUser?.id;

  @override
  Future<Either<Failure, List<WatchlistItem>>> getWatchlist() async {
    try {
      final userId = _currentUserId;
      if (userId != null) {
        try {
          final remoteModels = await remoteDataSource.getRemoteWatchlist(userId);
          for (var rItem in remoteModels) {
            final isLocal = await localDataSource.isWatchlisted(rItem.id);
            if (!isLocal) {
              await localDataSource.addToWatchlist(rItem);
            }
          }
        } catch (_) {
          // Graceful offline fallback
        }
      }

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

      final userId = _currentUserId;
      if (userId != null) {
        try {
          await remoteDataSource.upsertRemoteWatchlist(userId, model);
        } catch (_) {}
      }
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

      final userId = _currentUserId;
      if (userId != null) {
        try {
          await remoteDataSource.upsertRemoteWatchlist(userId, model);
        } catch (_) {}
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeFromWatchlist(int movieId) async {
    try {
      await localDataSource.removeFromWatchlist(movieId);

      final userId = _currentUserId;
      if (userId != null) {
        try {
          await remoteDataSource.deleteRemoteWatchlist(userId, movieId);
        } catch (_) {}
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleWatched(int movieId, bool daXem) async {
    try {
      await localDataSource.toggleWatched(movieId, daXem);

      final userId = _currentUserId;
      if (userId != null) {
        try {
          final localItems = await localDataSource.getWatchlist();
          final item = localItems.firstWhere((i) => i.id == movieId);
          await remoteDataSource.upsertRemoteWatchlist(userId, item);
        } catch (_) {}
      }
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

  @override
  Future<Either<Failure, void>> syncWatchlist() async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        return const Right(null);
      }

      final localModels = await localDataSource.getWatchlist();
      final remoteModels = await remoteDataSource.getRemoteWatchlist(userId);

      final localMap = {for (var item in localModels) item.id: item};
      final remoteMap = {for (var item in remoteModels) item.id: item};

      // Push local items to remote if missing
      for (var lItem in localModels) {
        if (!remoteMap.containsKey(lItem.id)) {
          await remoteDataSource.upsertRemoteWatchlist(userId, lItem);
        }
      }

      // Pull remote items to local if missing
      for (var rItem in remoteModels) {
        if (!localMap.containsKey(rItem.id)) {
          await localDataSource.addToWatchlist(rItem);
        }
      }

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
