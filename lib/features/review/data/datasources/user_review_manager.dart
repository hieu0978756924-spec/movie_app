import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../profile/data/user_profile_manager.dart';

class UserReviewItem {
  final int movieId;
  final String? movieTitle;
  final String? moviePoster;
  final double rating;
  final String content;
  final String authorName;
  final DateTime createdAt;
  final String? userId;

  const UserReviewItem({
    required this.movieId,
    this.movieTitle,
    this.moviePoster,
    required this.rating,
    required this.content,
    required this.authorName,
    required this.createdAt,
    this.userId,
  });

  Map<String, dynamic> toJson() => {
        'movieId': movieId,
        'movieTitle': movieTitle,
        'moviePoster': moviePoster,
        'rating': rating,
        'content': content,
        'authorName': authorName,
        'createdAt': createdAt.toIso8601String(),
        'userId': userId,
      };

  factory UserReviewItem.fromJson(Map<String, dynamic> json) => UserReviewItem(
        movieId: json['movieId'] as int,
        movieTitle: json['movieTitle'] as String?,
        moviePoster: json['moviePoster'] as String?,
        rating: (json['rating'] as num).toDouble(),
        content: json['content'] as String? ?? '',
        authorName: json['authorName'] as String? ?? 'Bạn',
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
            : DateTime.now(),
        userId: json['userId'] as String?,
      );
}

class UserReviewManager {
  static const String _legacyKey1 = 'user_movie_reviews_json_v2';
  static const String _legacyKey2 = 'user_movie_reviews_json';
  String _currentUserKey = 'user_movie_reviews_guest';

  UserReviewManager._internal() {
    _cleanupLegacy();
    _loadReviews();
  }

  static final UserReviewManager instance = UserReviewManager._internal();

  final ValueNotifier<Map<int, UserReviewItem>> userReviewsNotifier =
      ValueNotifier<Map<int, UserReviewItem>>({});

  Map<int, UserReviewItem> get userReviews => userReviewsNotifier.value;

  Future<void> _cleanupLegacy() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_legacyKey1);
      await prefs.remove(_legacyKey2);
    } catch (_) {}
  }

  String _getKeyForUser([String? emailOrId]) {
    if (emailOrId != null && emailOrId.isNotEmpty) {
      return 'user_movie_reviews_${emailOrId.toLowerCase()}';
    }
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null && user.id.isNotEmpty) {
        return 'user_movie_reviews_${user.id}';
      }
    } catch (_) {}
    final email = UserProfileManager.instance.profile.value.email;
    if (email.isNotEmpty) {
      return 'user_movie_reviews_${email.toLowerCase()}';
    }
    return 'user_movie_reviews_guest';
  }

  Future<void> loadForUser([String? emailOrId]) async {
    _currentUserKey = _getKeyForUser(emailOrId);
    await _loadReviews();
  }

  Future<void> _loadReviews() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString(_currentUserKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final Map<String, dynamic> decoded = jsonDecode(jsonStr);
        final Map<int, UserReviewItem> map = {};
        decoded.forEach((key, value) {
          final id = int.tryParse(key);
          if (id != null && value is Map<String, dynamic>) {
            map[id] = UserReviewItem.fromJson(value);
          }
        });
        userReviewsNotifier.value = map;
        return;
      }
    } catch (_) {}

    userReviewsNotifier.value = {};
  }

  void clearReviews() {
    userReviewsNotifier.value = {};
    _saveReviews();
  }

  Future<void> _saveReviews() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final Map<String, dynamic> rawMap = {};
      userReviewsNotifier.value.forEach((key, value) {
        rawMap[key.toString()] = value.toJson();
      });
      await prefs.setString(_currentUserKey, jsonEncode(rawMap));
    } catch (_) {}
  }

  UserReviewItem? getUserReview(int movieId) {
    return userReviewsNotifier.value[movieId];
  }

  Future<void> saveUserReview({
    required int movieId,
    String? movieTitle,
    String? moviePoster,
    required double rating,
    required String content,
    String? authorName,
    String? userId,
  }) async {
    final currentMap = Map<int, UserReviewItem>.from(userReviewsNotifier.value);
    currentMap[movieId] = UserReviewItem(
      movieId: movieId,
      movieTitle: movieTitle ?? currentMap[movieId]?.movieTitle,
      moviePoster: moviePoster ?? currentMap[movieId]?.moviePoster,
      rating: rating,
      content: content,
      authorName: authorName ?? 'Bạn',
      createdAt: DateTime.now(),
      userId: userId,
    );
    userReviewsNotifier.value = currentMap;
    await _saveReviews();
  }

  Future<void> deleteUserReview(int movieId) async {
    final currentMap = Map<int, UserReviewItem>.from(userReviewsNotifier.value);
    if (currentMap.containsKey(movieId)) {
      currentMap.remove(movieId);
      userReviewsNotifier.value = currentMap;
      await _saveReviews();
    }
  }

  /// Calculates dynamic updated rating and vote count taking user's review into account
  ({double rating, int voteCount}) getAdjustedRating({
    required int movieId,
    required double originalRating,
    required int originalVoteCount,
  }) {
    final userReview = getUserReview(movieId);
    if (userReview == null) {
      return (rating: originalRating, voteCount: originalVoteCount);
    }

    if (originalVoteCount <= 0) {
      return (rating: userReview.rating, voteCount: 1);
    }

    final totalScore = (originalRating * originalVoteCount) + userReview.rating;
    final totalVotes = originalVoteCount + 1;
    final adjusted = totalScore / totalVotes;

    return (
      rating: double.parse(adjusted.toStringAsFixed(1)),
      voteCount: totalVotes,
    );
  }
}
