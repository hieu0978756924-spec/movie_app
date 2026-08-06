import 'movie_model.dart';

class MovieResponseModel {
  final int page;
  final List<MovieModel> results;
  final int totalPages;
  final int totalResults;

  MovieResponseModel({
    required this.page,
    required this.results,
    required this.totalPages,
    required this.totalResults,
  });

  factory MovieResponseModel.fromJson(Map<String, dynamic> json) {
    return MovieResponseModel(
      page: json['page'] as int? ?? 1,
      results: (json['results'] as List<dynamic>?)
              ?.map((e) => MovieModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalPages: json['total_pages'] as int? ?? 1,
      totalResults: json['total_results'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'results': results.map((e) => e.toJson()).toList(),
      'total_pages': totalPages,
      'total_results': totalResults,
    };
  }
}
