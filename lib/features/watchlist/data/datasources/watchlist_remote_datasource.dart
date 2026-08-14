import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/supabase_constants.dart';
import '../models/watchlist_item_model.dart';

abstract class WatchlistRemoteDataSource {
  Future<List<WatchlistItemModel>> getRemoteWatchlist(String userId);
  Future<void> upsertRemoteWatchlist(String userId, WatchlistItemModel item);
  Future<void> deleteRemoteWatchlist(String userId, int movieId);
}

@LazySingleton(as: WatchlistRemoteDataSource)
class WatchlistRemoteDataSourceImpl implements WatchlistRemoteDataSource {
  final SupabaseClient supabaseClient;

  WatchlistRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<List<WatchlistItemModel>> getRemoteWatchlist(String userId) async {
    final response = await supabaseClient
        .from(SupabaseConstants.watchlistTable)
        .select()
        .eq('user_id', userId);

    final List<WatchlistItemModel> items = [];
    for (var row in response as List) {
      if (row is Map) {
        items.add(WatchlistItemModel(
          id: row['movie_id'] as int? ?? 0,
          tenPhim: row['movie_title'] as String? ?? '',
          hinhAnh: row['poster_path'] as String? ?? '',
          backdropPath: row['backdrop_path'] as String?,
          diemDanhGia: (row['rating'] as num?)?.toDouble() ?? 0.0,
          theLoai: row['genre'] as String? ?? 'Phim',
          namPhatHanh: row['release_year'] as int? ?? 2026,
          daXem: row['watched'] as bool? ?? false,
          addedAt: row['added_at'] as String? ?? DateTime.now().toIso8601String(),
        ));
      }
    }
    return items;
  }

  @override
  Future<void> upsertRemoteWatchlist(String userId, WatchlistItemModel item) async {
    await supabaseClient.from(SupabaseConstants.watchlistTable).upsert(
      {
        'user_id': userId,
        'movie_id': item.id,
        'movie_title': item.tenPhim,
        'poster_path': item.hinhAnh,
        'backdrop_path': item.backdropPath,
        'rating': item.diemDanhGia,
        'genre': item.theLoai,
        'release_year': item.namPhatHanh,
        'watched': item.daXem,
        'added_at': item.addedAt,
      },
      onConflict: 'user_id,movie_id',
    );
  }

  @override
  Future<void> deleteRemoteWatchlist(String userId, int movieId) async {
    await supabaseClient
        .from(SupabaseConstants.watchlistTable)
        .delete()
        .eq('user_id', userId)
        .eq('movie_id', movieId);
  }
}
