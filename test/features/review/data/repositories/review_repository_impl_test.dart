import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/features/review/data/datasources/review_remote_datasource.dart';
import 'package:movie_app/features/review/data/models/review_model.dart';
import 'package:movie_app/features/review/data/models/review_response_model.dart';
import 'package:movie_app/features/review/data/repositories/review_repository_impl.dart';

class MockReviewRemoteDataSource extends Mock implements ReviewRemoteDataSource {}

void main() {
  late MockReviewRemoteDataSource mockRemoteDataSource;
  late ReviewRepositoryImpl repository;

  setUp(() {
    mockRemoteDataSource = MockReviewRemoteDataSource();
    repository = ReviewRepositoryImpl(mockRemoteDataSource);
  });

  const tModel = ReviewModel(
    id: '1',
    author: 'John Doe',
    avatarPath: '/avatar.jpg',
    rating: 8.5,
    content: 'Great watch!',
    createdAt: '2026-08-07T10:00:00.000Z',
  );

  const tResponse = ReviewResponseModel(
    page: 1,
    results: [tModel],
    totalPages: 2,
    totalResults: 20,
  );

  group('ReviewRepositoryImpl Tests', () {
    test('getMovieReviews returns Right(Tuple2(reviews, hasMore)) on success', () async {
      when(() => mockRemoteDataSource.getMovieReviews(123, page: 1))
          .thenAnswer((_) async => tResponse);

      final result = await repository.getMovieReviews(123, page: 1);

      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Should be Right'),
        (tuple) {
          expect(tuple.value1.length, equals(1));
          expect(tuple.value1.first.author, equals('John Doe'));
          expect(tuple.value2, isTrue);
        },
      );
    });

    test('submitReview calls remoteDataSource.submitReview and returns Right', () async {
      when(() => mockRemoteDataSource.submitReview(
            movieId: 123,
            rating: 9.0,
            content: 'Superb!',
          )).thenAnswer((_) async {});

      final result = await repository.submitReview(
        movieId: 123,
        rating: 9.0,
        content: 'Superb!',
      );

      expect(result.isRight(), isTrue);
      verify(() => mockRemoteDataSource.submitReview(
            movieId: 123,
            rating: 9.0,
            content: 'Superb!',
          )).called(1);
    });
  });
}
