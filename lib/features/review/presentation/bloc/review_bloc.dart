import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/review_repository.dart';
import 'review_event.dart';
import 'review_state.dart';

@injectable
class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
  final ReviewRepository reviewRepository;

  ReviewBloc(this.reviewRepository) : super(const ReviewInitialState()) {
    on<FetchMovieReviewsEvent>(_onFetchMovieReviews);
    on<LoadMoreMovieReviewsEvent>(_onLoadMoreMovieReviews);
    on<SubmitReviewEvent>(_onSubmitReview);
    on<DeleteReviewEvent>(_onDeleteReview);
  }

  Future<void> _onFetchMovieReviews(
    FetchMovieReviewsEvent event,
    Emitter<ReviewState> emit,
  ) async {
    emit(const ReviewLoadingState());
    final result = await reviewRepository.getMovieReviews(event.movieId, page: 1);
    result.fold(
      (failure) => emit(ReviewErrorState(failure.message)),
      (tuple) => emit(ReviewLoadedState(
        reviews: tuple.value1,
        hasMore: tuple.value2,
        page: 1,
      )),
    );
  }

  Future<void> _onLoadMoreMovieReviews(
    LoadMoreMovieReviewsEvent event,
    Emitter<ReviewState> emit,
  ) async {
    if (state is! ReviewLoadedState) return;
    final currentState = state as ReviewLoadedState;
    if (!currentState.hasMore || currentState.isLoadingMore) return;

    emit(currentState.copyWith(isLoadingMore: true));
    final nextPage = currentState.page + 1;

    final result = await reviewRepository.getMovieReviews(
      event.movieId,
      page: nextPage,
    );

    result.fold(
      (failure) => emit(currentState.copyWith(isLoadingMore: false)),
      (tuple) {
        final updatedReviews = List.of(currentState.reviews)..addAll(tuple.value1);
        emit(ReviewLoadedState(
          reviews: updatedReviews,
          hasMore: tuple.value2,
          page: nextPage,
          isLoadingMore: false,
        ));
      },
    );
  }

  Future<void> _onSubmitReview(
    SubmitReviewEvent event,
    Emitter<ReviewState> emit,
  ) async {
    final result = await reviewRepository.submitReview(
      movieId: event.movieId,
      movieTitle: event.movieTitle,
      moviePoster: event.moviePoster,
      rating: event.rating,
      content: event.content,
    );

    result.fold(
      (failure) => emit(ReviewErrorState(failure.message)),
      (_) {
        add(FetchMovieReviewsEvent(event.movieId));
      },
    );
  }

  Future<void> _onDeleteReview(
    DeleteReviewEvent event,
    Emitter<ReviewState> emit,
  ) async {
    final result = await reviewRepository.deleteReview(
      movieId: event.movieId,
      reviewId: event.reviewId,
    );

    result.fold(
      (failure) => emit(ReviewErrorState(failure.message)),
      (_) {
        add(FetchMovieReviewsEvent(event.movieId));
      },
    );
  }
}
