import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:movie_app/features/review/domain/entities/review.dart';
import 'package:movie_app/features/review/domain/repositories/review_repository.dart';
import 'package:movie_app/features/review/presentation/bloc/review_bloc.dart';
import 'package:movie_app/features/review/presentation/bloc/review_event.dart';
import 'package:movie_app/features/review/presentation/bloc/review_state.dart';

class MockReviewRepository extends Mock implements ReviewRepository {}

void main() {
  late MockReviewRepository mockRepository;
  late ReviewBloc reviewBloc;

  setUp(() {
    mockRepository = MockReviewRepository();
    reviewBloc = ReviewBloc(mockRepository);
  });

  final tReview = Review(
    id: '1',
    author: 'Alice',
    rating: 9.0,
    content: 'Masterpiece',
    createdAt: DateTime.parse('2026-08-07T10:00:00.000Z'),
  );

  group('ReviewBloc Tests', () {
    test('initial state is ReviewInitialState', () {
      expect(reviewBloc.state, equals(const ReviewInitialState()));
    });

    blocTest<ReviewBloc, ReviewState>(
      'emits [ReviewLoadingState, ReviewLoadedState] when FetchMovieReviewsEvent succeeds',
      build: () {
        when(() => mockRepository.getMovieReviews(100, page: 1))
            .thenAnswer((_) async => Right(Tuple2([tReview], true)));
        return reviewBloc;
      },
      act: (bloc) => bloc.add(const FetchMovieReviewsEvent(100)),
      expect: () => [
        const ReviewLoadingState(),
        ReviewLoadedState(
          reviews: [tReview],
          hasMore: true,
          page: 1,
        ),
      ],
    );

    blocTest<ReviewBloc, ReviewState>(
      'emits [ReviewLoadingState, ReviewLoadedState] when SubmitReviewEvent succeeds',
      build: () {
        when(() => mockRepository.submitReview(
              movieId: 100,
              rating: 9.0,
              content: 'Masterpiece',
            )).thenAnswer((_) async => const Right(null));
        when(() => mockRepository.getMovieReviews(100, page: 1))
            .thenAnswer((_) async => Right(Tuple2([tReview], true)));
        return reviewBloc;
      },
      act: (bloc) => bloc.add(const SubmitReviewEvent(
        movieId: 100,
        rating: 9.0,
        content: 'Masterpiece',
      )),
      expect: () => [
        const ReviewLoadingState(),
        ReviewLoadedState(
          reviews: [tReview],
          hasMore: true,
          page: 1,
        ),
      ],
    );

    blocTest<ReviewBloc, ReviewState>(
      'emits updated ReviewLoadedState with concatenated reviews when LoadMoreMovieReviewsEvent succeeds',
      build: () {
        when(() => mockRepository.getMovieReviews(100, page: 2))
            .thenAnswer((_) async => Right(Tuple2([tReview], false)));
        return reviewBloc;
      },
      seed: () => ReviewLoadedState(
        reviews: [tReview],
        hasMore: true,
        page: 1,
      ),
      act: (bloc) => bloc.add(const LoadMoreMovieReviewsEvent(100)),
      expect: () => [
        ReviewLoadedState(
          reviews: [tReview],
          hasMore: true,
          page: 1,
          isLoadingMore: true,
        ),
        ReviewLoadedState(
          reviews: [tReview, tReview],
          hasMore: false,
          page: 2,
          isLoadingMore: false,
        ),
      ],
    );
  });
}
