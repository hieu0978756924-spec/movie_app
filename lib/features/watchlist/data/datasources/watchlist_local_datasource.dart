import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';
import '../models/watchlist_item_model.dart';

abstract class WatchlistLocalDataSource {
  Future<List<WatchlistItemModel>> getWatchlist();
  Future<void> addToWatchlist(WatchlistItemModel item);
  Future<void> removeFromWatchlist(int id);
  Future<void> toggleWatched(int id, bool daXem);
  Future<bool> isWatchlisted(int id);
}

@LazySingleton(as: WatchlistLocalDataSource)
class WatchlistLocalDataSourceImpl implements WatchlistLocalDataSource {
  static const String boxName = 'watchlist_box';

  Future<Box> _getBox() async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box(boxName);
    }
    return await Hive.openBox(boxName);
  }

  @override
  Future<List<WatchlistItemModel>> getWatchlist() async {
    final box = await _getBox();
    final List<WatchlistItemModel> items = [];
    for (var key in box.keys) {
      final data = box.get(key);
      if (data != null && data is Map) {
        items.add(WatchlistItemModel.fromMap(data));
      }
    }
    items.sort((a, b) => b.addedAt.compareTo(a.addedAt));
    return items;
  }

  @override
  Future<void> addToWatchlist(WatchlistItemModel item) async {
    final box = await _getBox();
    await box.put(item.id, item.toMap());
  }

  @override
  Future<void> removeFromWatchlist(int id) async {
    final box = await _getBox();
    await box.delete(id);
  }

  @override
  Future<void> toggleWatched(int id, bool daXem) async {
    final box = await _getBox();
    final data = box.get(id);
    if (data != null && data is Map) {
      final updatedMap = Map<String, dynamic>.from(data);
      updatedMap['daXem'] = daXem;
      await box.put(id, updatedMap);
    }
  }

  @override
  Future<bool> isWatchlisted(int id) async {
    final box = await _getBox();
    return box.containsKey(id);
  }
}
