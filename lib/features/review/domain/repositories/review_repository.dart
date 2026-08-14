import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/review.dart';

abstract class ReviewRepository {
  Future<Either<Failure, Tuple2<List<Review>, bool>>> getMovieReviews(
    int movieId, {
    int page = 1,
  });

  Future<Either<Failure, void>> submitReview({
    required int movieId,
    required double rating,
    required String content,
  });
}
