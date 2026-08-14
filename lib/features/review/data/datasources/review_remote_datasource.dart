import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/supabase_constants.dart';
import '../models/review_model.dart';
import '../models/review_response_model.dart';

abstract class ReviewRemoteDataSource {
  Future<ReviewResponseModel> getMovieReviews(int movieId, {int page = 1});
  Future<void> submitReview({
    required int movieId,
    required double rating,
    required String content,
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
      try {
        final supabaseRows = await supabaseClient
            .from(SupabaseConstants.reviewsTable)
            .select()
            .eq('movie_id', movieId)
            .order('updated_at', ascending: false);

        final List<ReviewModel> userReviews = [];
        for (var row in supabaseRows as List) {
          if (row is Map) {
            userReviews.add(ReviewModel(
              id: 'sb_${row['id']}',
              author: 'Thành viên Góc Phim',
              avatarPath: null,
              rating: (row['rating'] as num?)?.toDouble() ?? 0.0,
              content: row['content'] as String? ?? '',
              createdAt: row['updated_at'] as String? ?? DateTime.now().toIso8601String(),
            ));
          }
        }
        return ReviewResponseModel(
          page: tmdbResult.page,
          results: [...userReviews, ...tmdbResult.results],
          totalPages: tmdbResult.totalPages,
          totalResults: tmdbResult.totalResults + userReviews.length,
        );
      } catch (_) {}
    }

    return tmdbResult;
  }

  @override
  Future<void> submitReview({
    required int movieId,
    required double rating,
    required String content,
  }) async {
    final user = supabaseClient.auth.currentUser;
    if (user == null) {
      throw Exception('Vui lòng đăng nhập để gửi đánh giá');
    }

    await supabaseClient.from(SupabaseConstants.reviewsTable).upsert({
      'user_id': user.id,
      'movie_id': movieId,
      'rating': rating,
      'content': content,
      'updated_at': DateTime.now().toIso8601String(),
    }, onConflict: 'user_id,movie_id');
  }
}
