import '../../domain/entities/review.dart';
import '../../../../core/utils/image_url_helper.dart';

class ReviewModel {
  final String id;
  final String author;
  final String? avatarPath;
  final double rating;
  final String content;
  final String createdAt;

  const ReviewModel({
    required this.id,
    required this.author,
    this.avatarPath,
    required this.rating,
    required this.content,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    String authorName = json['author'] as String? ?? '';
    String? avatar;
    double score = 0.0;

    final authorDetails = json['author_details'];
    if (authorDetails is Map<String, dynamic>) {
      if (authorName.isEmpty) {
        authorName = authorDetails['name'] as String? ??
            authorDetails['username'] as String? ??
            'Ẩn danh';
      }
      avatar = authorDetails['avatar_path'] as String?;
      score = (authorDetails['rating'] as num?)?.toDouble() ?? 0.0;
    }

    if (authorName.isEmpty) {
      authorName = 'Ẩn danh';
    }

    if (score == 0.0 && json['rating'] != null) {
      score = (json['rating'] as num).toDouble();
    }

    if (score > 5.0) {
      score = score / 2.0;
    }

    return ReviewModel(
      id: json['id']?.toString() ?? '',
      author: authorName,
      avatarPath: avatar ?? json['avatar_url'] as String?,
      rating: score,
      content: json['content'] as String? ?? '',
      createdAt:
          json['created_at'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  Review toEntity() {
    String? fullAvatar = avatarPath;
    if (fullAvatar != null) {
      if (fullAvatar.startsWith('/http://') ||
          fullAvatar.startsWith('/https://')) {
        fullAvatar = fullAvatar.substring(1);
      } else if (!fullAvatar.startsWith('http://') &&
          !fullAvatar.startsWith('https://')) {
        fullAvatar = ImageUrlHelper.getProfileUrl(fullAvatar);
      }
    }

    return Review(
      id: id,
      author: author,
      avatarUrl: fullAvatar,
      rating: rating,
      content: content,
      createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
    );
  }
}
