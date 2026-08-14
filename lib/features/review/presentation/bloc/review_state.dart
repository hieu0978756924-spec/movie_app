import 'package:equatable/equatable.dart';
import '../../domain/entities/review.dart';

abstract class ReviewState extends Equatable {
  const ReviewState();

  @override
  List<Object?> get props => [];
}

class ReviewInitialState extends ReviewState {
  const ReviewInitialState();
}

class ReviewLoadingState extends ReviewState {
  const ReviewLoadingState();
}

class ReviewLoadedState extends ReviewState {
  final List<Review> reviews;
  final bool hasMore;
  final int page;
  final bool isLoadingMore;

  const ReviewLoadedState({
    required this.reviews,
    required this.hasMore,
    required this.page,
    this.isLoadingMore = false,
  });

  ReviewLoadedState copyWith({
    List<Review>? reviews,
    bool? hasMore,
    int? page,
    bool? isLoadingMore,
  }) {
    return ReviewLoadedState(
      reviews: reviews ?? this.reviews,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [reviews, hasMore, page, isLoadingMore];
}

class ReviewErrorState extends ReviewState {
  final String message;

  const ReviewErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
