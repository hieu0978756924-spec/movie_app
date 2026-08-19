import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../home/models/movie.dart';
import 'user_profile_manager.dart';

class WatchedVideoItem {
  final Movie movie;
  final String watchedAt;
  final double progress; // 0.0 to 1.0

  const WatchedVideoItem({
    required this.movie,
    required this.watchedAt,
    required this.progress,
  });

  Map<String, dynamic> toJson() => {
        'movie': movie.toJson(),
        'watchedAt': watchedAt,
        'progress': progress,
      };

  factory WatchedVideoItem.fromJson(Map<String, dynamic> json) =>
      WatchedVideoItem(
        movie: Movie.fromJson(json['movie'] as Map<String, dynamic>),
        watchedAt: json['watchedAt'] as String? ?? 'Mới xong',
        progress: (json['progress'] as num?)?.toDouble() ?? 1.0,
      );
}

class WatchHistoryManager {
  static const String _legacyKey1 = 'watched_video_history_json';
  static const String _legacyKey2 = 'watched_video_history_guest';
  String _currentUserKey = 'watched_video_history_v3_guest';

  WatchHistoryManager._internal() {
    history = ValueNotifier<List<WatchedVideoItem>>([]);
    _cleanupLegacy();
    _loadHistory();
  }

  static final WatchHistoryManager instance = WatchHistoryManager._internal();

  late final ValueNotifier<List<WatchedVideoItem>> history;

  Future<void> _cleanupLegacy() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_legacyKey1);
      await prefs.remove(_legacyKey2);
    } catch (_) {}
  }

  String _getKeyForUser([String? emailOrId]) {
    if (emailOrId != null && emailOrId.isNotEmpty && emailOrId != 'guest') {
      return 'watched_video_history_v3_${emailOrId.toLowerCase()}';
    }
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null && user.id.isNotEmpty) {
        return 'watched_video_history_v3_${user.id}';
      }
    } catch (_) {}
    final email = UserProfileManager.instance.profile.value.email;
    if (email.isNotEmpty) {
      return 'watched_video_history_v3_${email.toLowerCase()}';
    }
    return 'watched_video_history_v3_guest';
  }

  Future<void> loadForUser([String? emailOrId]) async {
    _currentUserKey = _getKeyForUser(emailOrId);
    await _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString(_currentUserKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> list = jsonDecode(jsonStr);
        history.value = list
            .map((e) => WatchedVideoItem.fromJson(e as Map<String, dynamic>))
            .toList();
        return;
      }
    } catch (_) {}

    history.value = [];
  }

  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr =
          jsonEncode(history.value.map((e) => e.toJson()).toList());
      await prefs.setString(_currentUserKey, jsonStr);
    } catch (_) {}
  }

  void addWatchedVideo(Movie movie, {double progress = 1.0}) {
    final currentList = List<WatchedVideoItem>.from(history.value);
    currentList.removeWhere((item) => item.movie.id == movie.id);
    currentList.insert(
      0,
      WatchedVideoItem(
        movie: movie,
        watchedAt: 'Mới xong',
        progress: progress,
      ),
    );
    history.value = currentList;
    _saveHistory();
  }

  void removeItemAt(int index) {
    if (index >= 0 && index < history.value.length) {
      final currentList = List<WatchedVideoItem>.from(history.value);
      currentList.removeAt(index);
      history.value = currentList;
      _saveHistory();
    }
  }

  void removeItemById(int movieId) {
    final currentList = List<WatchedVideoItem>.from(history.value);
    currentList.removeWhere((item) => item.movie.id == movieId);
    history.value = currentList;
    _saveHistory();
  }

  void clearHistory() {
    history.value = [];
    _saveHistory();
  }
}
