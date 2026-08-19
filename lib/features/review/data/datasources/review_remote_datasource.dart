import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/supabase_constants.dart';
import '../models/review_model.dart';
import '../models/review_response_model.dart';
import 'user_review_manager.dart';

abstract class ReviewRemoteDataSource {
  Future<ReviewResponseModel> getMovieReviews(int movieId, {int page = 1});
  Future<void> submitReview({
    required int movieId,
    String? movieTitle,
    String? moviePoster,
    required double rating,
    required String content,
  });
  Future<void> deleteReview({
    required int movieId,
    String? reviewId,
  });
}

@LazySingleton(as: ReviewRemoteDataSource)
class ReviewRemoteDataSourceImpl implements ReviewRemoteDataSource {
  final Dio dio;
  final SupabaseClient supabaseClient;

  ReviewRemoteDataSourceImpl(this.dio, this.supabaseClient);

  @override
  Future<ReviewResponseModel> getMovieReviews(int movieId, {int page = 1}) async {
    final response = await dio.get(
      '/movie/$movieId/reviews',
      queryParameters: {'page': page},
    );
    final tmdbResult = ReviewResponseModel.fromJson(response.data as Map<String, dynamic>);

    if (page == 1) {
      final List<ReviewModel> userReviews = [];

      // 1. Check local UserReviewManager
      final localReview = UserReviewManager.instance.getUserReview(movieId);
      if (localReview != null) {
        userReviews.add(ReviewModel(
          id: 'local_user_${localReview.movieId}',
          author: '${localReview.authorName} (Bạn)',
          avatarPath: null,
          rating: localReview.rating,
          content: localReview.content,
          createdAt: localReview.createdAt.toIso8601String(),
        ));
      }

      // 2. Fetch from Supabase
      try {
        final supabaseRows = await supabaseClient
            .from(SupabaseConstants.reviewsTable)
            .select()
            .eq('movie_id', movieId)
            .order('updated_at', ascending: false);

        final currentUserId = supabaseClient.auth.currentUser?.id;

        for (var row in supabaseRows as List) {
          if (row is Map) {
            final rowUserId = row['user_id'] as String?;
            // Skip if it is current user's review and we already added localReview
            if (localReview != null && currentUserId != null && rowUserId == currentUserId) {
              continue;
            }

            userReviews.add(ReviewModel(
              id: 'sb_${row['id']}',
              author: (currentUserId != null && rowUserId == currentUserId)
                  ? 'Bạn'
                  : 'Thành viên Góc Phim',
              avatarPath: null,
              rating: (row['rating'] as num?)?.toDouble() ?? 0.0,
              content: row['content'] as String? ?? '',
              createdAt: row['updated_at'] as String? ?? DateTime.now().toIso8601String(),
            ));
          }
        }
      } catch (_) {}

      if (userReviews.isNotEmpty) {
        return ReviewResponseModel(
          page: tmdbResult.page,
          results: [...userReviews, ...tmdbResult.results],
          totalPages: tmdbResult.totalPages,
          totalResults: tmdbResult.totalResults + userReviews.length,
        );
      }
    }

    return tmdbResult;
  }

  @override
  Future<void> submitReview({
    required int movieId,
    String? movieTitle,
    String? moviePoster,
    required double rating,
    required String content,
  }) async {
    final user = supabaseClient.auth.currentUser;
    String authorName = 'Bạn';

    if (user != null) {
      final meta = user.userMetadata;
      if (meta != null) {
        authorName = meta['display_name'] ?? meta['name'] ?? meta['full_name'] ?? authorName;
      }
      if (authorName == 'Bạn' && user.email != null && user.email!.isNotEmpty) {
        authorName = user.email!.split('@').first;
      }
    }

    // Save locally immediately with movie metadata
    await UserReviewManager.instance.saveUserReview(
      movieId: movieId,
      movieTitle: movieTitle,
      moviePoster: moviePoster,
      rating: rating,
      content: content,
      authorName: authorName,
      userId: user?.id,
    );

    // Save to Supabase if authenticated
    if (user != null) {
      try {
        await supabaseClient.from(SupabaseConstants.reviewsTable).upsert({
          'user_id': user.id,
          'movie_id': movieId,
          'rating': rating,
          'content': content,
          'updated_at': DateTime.now().toIso8601String(),
        }, onConflict: 'user_id,movie_id');
      } catch (_) {
        // Local save succeeded, allow offline or fallback operation
      }
    }
  }

  @override
  Future<void> deleteReview({
    required int movieId,
    String? reviewId,
  }) async {
    // 1. Delete from local UserReviewManager
    await UserReviewManager.instance.deleteUserReview(movieId);

    // 2. Delete from Supabase if authenticated
    final user = supabaseClient.auth.currentUser;
    if (user != null) {
      try {
        await supabaseClient
            .from(SupabaseConstants.reviewsTable)
            .delete()
            .match({'user_id': user.id, 'movie_id': movieId});
      } catch (_) {}
    }
  }
}
