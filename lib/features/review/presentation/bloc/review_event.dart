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
  final double rating;
  final String content;

  const SubmitReviewEvent({
    required this.movieId,
    required this.rating,
    required this.content,
  });

  @override
  List<Object?> get props => [movieId, rating, content];
}
