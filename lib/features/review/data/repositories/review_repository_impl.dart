import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/error_handler.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/review.dart';
import '../../domain/repositories/review_repository.dart';
import '../datasources/review_remote_datasource.dart';

@LazySingleton(as: ReviewRepository)
class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewRemoteDataSource remoteDataSource;

  ReviewRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, Tuple2<List<Review>, bool>>> getMovieReviews(
    int movieId, {
    int page = 1,
  }) async {
    try {
      final response = await remoteDataSource.getMovieReviews(
        movieId,
        page: page,
      );
      final reviews = response.results.map((m) => m.toEntity()).toList();
      final hasMore = response.page < response.totalPages;
      return Right(Tuple2(reviews, hasMore));
    } catch (e) {
      return Left(parseFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> submitReview({
    required int movieId,
    required double rating,
    required String content,
  }) async {
    try {
      await remoteDataSource.submitReview(
        movieId: movieId,
        rating: rating,
        content: content,
      );
      return const Right(null);
    } catch (e) {
      return Left(parseFailure(e));
    }
  }
}
