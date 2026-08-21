import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/user_session.dart';
import '../bloc/review_bloc.dart';
import '../bloc/review_event.dart';
import '../bloc/review_state.dart';
import 'review_card_widget.dart';
import 'write_review_bottom_sheet.dart';

class ReviewListWidget extends StatelessWidget {
  final int movieId;
  final String? movieTitle;
  final String? moviePoster;

  const ReviewListWidget({
    super.key,
    required this.movieId,
    this.movieTitle,
    this.moviePoster,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ReviewBloc>(
      create: (_) => getIt<ReviewBloc>()..add(FetchMovieReviewsEvent(movieId)),
      child: _ReviewListContent(
        movieId: movieId,
        movieTitle: movieTitle,
        moviePoster: moviePoster,
      ),
    );
  }
}

class _ReviewListContent extends StatefulWidget {
  final int movieId;
  final String? movieTitle;
  final String? moviePoster;

  const _ReviewListContent({
    required this.movieId,
    this.movieTitle,
    this.moviePoster,
  });

  @override
  State<_ReviewListContent> createState() => _ReviewListContentState();
}

class _ReviewListContentState extends State<_ReviewListContent> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<ReviewBloc>().add(LoadMoreMovieReviewsEvent(widget.movieId));
    }
  }

  void _onWriteReviewPressed(BuildContext context) {
    UserSession.instance.requireAuth(
      context,
      actionName: 'viết đánh giá & bình luận',
      onAuthenticated: () {
        WriteReviewBottomSheet.show(
          context,
          movieId: widget.movieId,
          movieTitle: widget.movieTitle,
          moviePoster: widget.moviePoster,
        );
      },
    );
  }

  void _onDeleteReviewPressed(BuildContext context) {
    context.read<ReviewBloc>().add(
          DeleteReviewEvent(movieId: widget.movieId),
        );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã xóa đánh giá của bạn!'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<ReviewBloc, ReviewState>(
      builder: (context, state) {
        if (state is ReviewLoadingState) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primaryRed),
            ),
          );
        }

        if (state is ReviewErrorState) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'Không thể tải đánh giá',
                style: TextStyle(
                  color: isDark
                      ? AppColors.darkTextMuted
                      : AppColors.lightTextMuted,
                ),
              ),
            ),
          );
        }

        if (state is ReviewLoadedState) {
          final reviews = state.reviews;

          if (reviews.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Icon(
                    Icons.rate_review_outlined,
                    size: 48,
                    color: isDark
                        ? AppColors.darkTextMuted
                        : AppColors.lightTextMuted,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Chưa có đánh giá nào cho bộ phim này',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? AppColors.darkTextMuted
                          : AppColors.lightTextMuted,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryRed,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => _onWriteReviewPressed(context),
                    icon: const Icon(Icons.edit_note_rounded),
                    label: const Text('Viết đánh giá đầu tiên'),
                  ),
                ],
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Đánh giá & Bình luận (${reviews.length})',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _onWriteReviewPressed(context),
                    icon: const Icon(
                      Icons.edit_note_rounded,
                      color: AppColors.primaryRed,
                      size: 20,
                    ),
                    label: const Text(
                      'Viết đánh giá',
                      style: TextStyle(
                        color: AppColors.primaryRed,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ListView.builder(
                controller: _scrollController,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: reviews.length + (state.isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < reviews.length) {
                    return ReviewCardWidget(
                      review: reviews[index],
                      onEdit: () => _onWriteReviewPressed(context),
                      onDelete: () => _onDeleteReviewPressed(context),
                    );
                  }
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryRed,
                        strokeWidth: 2,
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
