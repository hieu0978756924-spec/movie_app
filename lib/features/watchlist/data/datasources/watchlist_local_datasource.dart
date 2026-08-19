import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../profile/data/user_profile_manager.dart';
import '../models/watchlist_item_model.dart';

abstract class WatchlistLocalDataSource {
  Future<List<WatchlistItemModel>> getWatchlist();
  Future<void> addToWatchlist(WatchlistItemModel item);
  Future<void> removeFromWatchlist(int id);
  Future<void> toggleWatched(int id, bool daXem);
  Future<bool> isWatchlisted(int id);
  Future<void> clearWatchlist();
}

@LazySingleton(as: WatchlistLocalDataSource)
class WatchlistLocalDataSourceImpl implements WatchlistLocalDataSource {
  static const String baseBoxName = 'watchlist_box';

  String _getBoxName() {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null && user.id.isNotEmpty) {
        return '${baseBoxName}_${user.id.replaceAll('-', '_')}';
      }
    } catch (_) {}
    final email = UserProfileManager.instance.profile.value.email;
    if (email.isNotEmpty) {
      return '${baseBoxName}_${email.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}';
    }
    return baseBoxName;
  }

  Future<Box?> _getBox() async {
    try {
      final name = _getBoxName();
      if (Hive.isBoxOpen(name)) {
        return Hive.box(name);
      }
      return await Hive.openBox(name);
    } catch (_) {
      try {
        if (Hive.isBoxOpen(baseBoxName)) {
          return Hive.box(baseBoxName);
        }
        return await Hive.openBox(baseBoxName);
      } catch (_) {
        return null;
      }
    }
  }

  @override
  Future<List<WatchlistItemModel>> getWatchlist() async {
    try {
      final box = await _getBox();
      if (box == null) return [];
      final List<WatchlistItemModel> items = [];
      for (var key in box.keys) {
        final data = box.get(key);
        if (data != null && data is Map) {
          items.add(WatchlistItemModel.fromMap(data));
        }
      }
      items.sort((a, b) => b.addedAt.compareTo(a.addedAt));
      return items;
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> addToWatchlist(WatchlistItemModel item) async {
    try {
      final box = await _getBox();
      if (box == null) return;
      await box.put(item.id, item.toMap());
      await box.flush();
    } catch (_) {}
  }

  @override
  Future<void> removeFromWatchlist(int id) async {
    try {
      final box = await _getBox();
      if (box == null) return;
      await box.delete(id);
      await box.flush();
    } catch (_) {}
  }

  @override
  Future<void> toggleWatched(int id, bool daXem) async {
    try {
      final box = await _getBox();
      if (box == null) return;
      final data = box.get(id);
      if (data != null && data is Map) {
        final updatedMap = Map<String, dynamic>.from(data);
        updatedMap['daXem'] = daXem;
        await box.put(id, updatedMap);
        await box.flush();
      }
    } catch (_) {}
  }

  @override
  Future<bool> isWatchlisted(int id) async {
    try {
      final box = await _getBox();
      if (box == null) return false;
      return box.containsKey(id);
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> clearWatchlist() async {
    try {
      final box = await _getBox();
      if (box == null) return;
      await box.clear();
      await box.flush();
    } catch (_) {}
  }
}
