import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/review_bloc.dart';
import '../bloc/review_event.dart';
import '../bloc/review_state.dart';
import 'review_card_widget.dart';
import 'write_review_bottom_sheet.dart';

class ReviewListWidget extends StatelessWidget {
  final int movieId;

  const ReviewListWidget({super.key, required this.movieId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ReviewBloc>(
      create: (_) => getIt<ReviewBloc>()..add(FetchMovieReviewsEvent(movieId)),
      child: _ReviewListContent(movieId: movieId),
    );
  }
}

class _ReviewListContent extends StatefulWidget {
  final int movieId;

  const _ReviewListContent({required this.movieId});

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
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Vui lòng đăng nhập để viết đánh giá'),
          backgroundColor: AppColors.error,
          action: SnackBarAction(
            label: 'Đăng nhập',
            textColor: AppColors.accentGold,
            onPressed: () {
              context.push(RoutePath.login);
            },
          ),
        ),
      );
      return;
    }
    WriteReviewBottomSheet.show(context, movieId: widget.movieId);
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
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
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
                    return ReviewCardWidget(review: reviews[index]);
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
