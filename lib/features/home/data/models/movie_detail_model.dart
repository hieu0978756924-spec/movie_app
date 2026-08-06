import 'package:json_annotation/json_annotation.dart';

import '../../models/movie.dart';

part 'movie_detail_model.g.dart';

@JsonSerializable()
class GenreModel {
  final int id;
  final String name;

  GenreModel({
    required this.id,
    required this.name,
  });

  factory GenreModel.fromJson(Map<String, dynamic> json) =>
      _$GenreModelFromJson(json);

  Map<String, dynamic> toJson() => _$GenreModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
class MovieDetailModel {
  final int id;
  final String title;
  @JsonKey(name: 'poster_path')
  final String? posterPath;
  @JsonKey(name: 'backdrop_path')
  final String? backdropPath;
  @JsonKey(name: 'vote_average')
  final double voteAverage;
  @JsonKey(name: 'vote_count')
  final int voteCount;
  final String overview;
  @JsonKey(name: 'release_date')
  final String? releaseDate;
  final int? runtime;
  final String? tagline;
  final String? status;
  final List<GenreModel> genres;

  MovieDetailModel({
    required this.id,
    required this.title,
    this.posterPath,
    this.backdropPath,
    required this.voteAverage,
    required this.voteCount,
    required this.overview,
    this.releaseDate,
    this.runtime,
    this.tagline,
    this.status,
    this.genres = const [],
  });

  factory MovieDetailModel.fromJson(Map<String, dynamic> json) =>
      _$MovieDetailModelFromJson(json);

  Map<String, dynamic> toJson() => _$MovieDetailModelToJson(this);

  Movie toEntity() {
    int year = 2026;
    if (releaseDate != null && releaseDate!.length >= 4) {
      year = int.tryParse(releaseDate!.substring(0, 4)) ?? 2026;
    }
    final genresString = genres.map((g) => g.name).join(', ');

    return Movie(
      id: id,
      tenPhim: title,
      hinhAnh: posterPath ?? '',
      backdropPath: backdropPath,
      diemDanhGia: voteAverage,
      theLoai: genresString.isNotEmpty ? genresString : 'Action',
      thoiLuong: runtime != null ? '$runtime min' : '120 min',
      moTa: overview,
      namPhatHanh: year,
      daoDien: tagline ?? 'TMDB Studio',
      genreIds: genres.map((g) => g.id).toList(),
      voteCount: voteCount,
    );
  }
}
