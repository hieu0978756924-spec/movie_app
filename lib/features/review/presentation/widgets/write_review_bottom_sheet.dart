import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/review_bloc.dart';
import '../bloc/review_event.dart';
import '../../data/datasources/user_review_manager.dart';

class WriteReviewBottomSheet extends StatefulWidget {
  final int movieId;
  final String? movieTitle;
  final String? moviePoster;

  const WriteReviewBottomSheet({
    super.key,
    required this.movieId,
    this.movieTitle,
    this.moviePoster,
  });

  static Future<void> show(
    BuildContext context, {
    required int movieId,
    String? movieTitle,
    String? moviePoster,
  }) {
    ReviewBloc bloc;
    try {
      bloc = context.read<ReviewBloc>();
    } catch (_) {
      bloc = getIt<ReviewBloc>();
    }
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: WriteReviewBottomSheet(
          movieId: movieId,
          movieTitle: movieTitle,
          moviePoster: moviePoster,
        ),
      ),
    );
  }

  @override
  State<WriteReviewBottomSheet> createState() => _WriteReviewBottomSheetState();
}

class _WriteReviewBottomSheetState extends State<WriteReviewBottomSheet> {
  double _selectedRating = 10.0;
  final TextEditingController _contentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final existing = UserReviewManager.instance.getUserReview(widget.movieId);
    if (existing != null) {
      _selectedRating = existing.rating;
      _contentController.text = existing.content;
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomPadding),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Viết đánh giá & Bình luận',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    color: isDark
                        ? AppColors.darkTextMuted
                        : AppColors.lightTextMuted,
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Star Rating Selector (1-10 stars)
              Text(
                'Điểm đánh giá: ${_selectedRating.toStringAsFixed(1)} / 10',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accentGold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(10, (index) {
                  final starValue = index + 1.0;
                  final isSelected = starValue <= _selectedRating;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedRating = starValue;
                      });
                    },
                    child: Icon(
                      isSelected
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: isSelected
                          ? AppColors.accentGold
                          : (isDark
                              ? AppColors.darkTextMuted
                              : AppColors.lightTextMuted),
                      size: 22,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),

              // Text Area
              TextFormField(
                controller: _contentController,
                maxLines: 4,
                style: TextStyle(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Chia sẻ cảm nhận của bạn về bộ phim này...',
                  hintStyle: TextStyle(
                    color: isDark
                        ? AppColors.darkTextMuted
                        : AppColors.lightTextMuted,
                  ),
                  filled: true,
                  fillColor: isDark ? AppColors.darkCard : AppColors.lightCard,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập nội dung đánh giá';
                  }
                  if (value.trim().length < 5) {
                    return 'Nội dung đánh giá cần ít nhất 5 ký tự';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      context.read<ReviewBloc>().add(
                            SubmitReviewEvent(
                              movieId: widget.movieId,
                              movieTitle: widget.movieTitle,
                              moviePoster: widget.moviePoster,
                              rating: _selectedRating,
                              content: _contentController.text.trim(),
                            ),
                          );
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Đã gửi đánh giá của bạn!'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.send_rounded, color: Colors.white),
                  label: const Text(
                    'Gửi đánh giá',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
