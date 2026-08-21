import 'review_model.dart';

class ReviewResponseModel {
  final int page;
  final List<ReviewModel> results;
  final int totalPages;
  final int totalResults;

  const ReviewResponseModel({
    required this.page,
    required this.results,
    required this.totalPages,
    required this.totalResults,
  });

  factory ReviewResponseModel.fromJson(Map<String, dynamic> json) {
    final list = json['results'] as List? ?? [];
    return ReviewResponseModel(
      page: json['page'] as int? ?? 1,
      results: list
          .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalPages: json['total_pages'] as int? ?? 1,
      totalResults: json['total_results'] as int? ?? 0,
    );
  }
}
