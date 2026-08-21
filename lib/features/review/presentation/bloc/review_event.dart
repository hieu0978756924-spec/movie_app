import 'package:equatable/equatable.dart';

abstract class ReviewEvent extends Equatable {
  const ReviewEvent();

  @override
  List<Object?> get props => [];
}

class FetchMovieReviewsEvent extends ReviewEvent {
  final int movieId;

  const FetchMovieReviewsEvent(this.movieId);

  @override
  List<Object?> get props => [movieId];
}

class LoadMoreMovieReviewsEvent extends ReviewEvent {
  final int movieId;

  const LoadMoreMovieReviewsEvent(this.movieId);

  @override
  List<Object?> get props => [movieId];
}

class SubmitReviewEvent extends ReviewEvent {
  final int movieId;
  final String? movieTitle;
  final String? moviePoster;
  final double rating;
  final String content;

  const SubmitReviewEvent({
    required this.movieId,
    this.movieTitle,
    this.moviePoster,
    required this.rating,
    required this.content,
  });

  @override
  List<Object?> get props =>
      [movieId, movieTitle, moviePoster, rating, content];
}

class DeleteReviewEvent extends ReviewEvent {
  final int movieId;
  final String? reviewId;

  const DeleteReviewEvent({
    required this.movieId,
    this.reviewId,
  });

  @override
  List<Object?> get props => [movieId, reviewId];
}
