import '../../models/movie.dart';

class MovieModel {
  final int id;
  final String title;
  final String? posterPath;
  final String? backdropPath;
  final double voteAverage;
  final String? releaseDate;
  final String overview;
  final List<int> genreIds;
  final int voteCount;

  MovieModel({
    required this.id,
    required this.title,
    this.posterPath,
    this.backdropPath,
    required this.voteAverage,
    this.releaseDate,
    required this.overview,
    required this.genreIds,
    required this.voteCount,
  });

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? json['name'] as String? ?? '',
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      releaseDate: json['release_date'] as String? ?? json['first_air_date'] as String?,
      overview: json['overview'] as String? ?? '',
      genreIds: (json['genre_ids'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
      voteCount: json['vote_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'poster_path': posterPath,
      'backdrop_path': backdropPath,
      'vote_average': voteAverage,
      'release_date': releaseDate,
      'overview': overview,
      'genre_ids': genreIds,
      'vote_count': voteCount,
    };
  }

  Movie toEntity() {
    int year = 2026;
    if (releaseDate != null && releaseDate!.length >= 4) {
      year = int.tryParse(releaseDate!.substring(0, 4)) ?? 2026;
    }

    return Movie(
      id: id,
      tenPhim: title,
      hinhAnh: posterPath ?? '',
      backdropPath: backdropPath,
      diemDanhGia: voteAverage > 5.0 ? voteAverage / 2.0 : voteAverage,
      moTa: overview,
      namPhatHanh: year,
      genreIds: genreIds,
      voteCount: voteCount,
    );
  }
}
