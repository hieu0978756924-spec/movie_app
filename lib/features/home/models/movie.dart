import 'package:equatable/equatable.dart';

class MovieCastMember extends Equatable {
  final int actorId;
  final String characterName;

  const MovieCastMember({
    required this.actorId,
    required this.characterName,
  });

  factory MovieCastMember.fromJson(Map<String, dynamic> json) {
    return MovieCastMember(
      actorId: json['actorId'] ?? 0,
      characterName: json['characterName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'actorId': actorId,
        'characterName': characterName,
      };

  @override
  List<Object?> get props => [actorId, characterName];
}

// ignore: must_be_immutable
class Movie extends Equatable {
  final int id;
  final String tenPhim;
  final String originalTitle;
  final String hinhAnh;
  final String backdropPath;
  final double diemDanhGia;
  final int voteCount;
  final String releaseDate;
  final int runtime;
  final String theLoai;
  final List<String> genres;
  final List<int> genreIds;
  final String moTa;

  final String daoDien;
  final int _namPhatHanhCustom;
  final String _thoiLuongCustom;
  final bool isHot;
  final bool isNowPlaying;
  final bool isPopular;
  final bool isTopRated;
  final bool isUpcoming;
  final String trailerUrl;
  final String videoUrl;
  final List<MovieCastMember> cast;
  bool yeuThich;

  Movie({
    this.id = 0,
    required this.tenPhim,
    this.originalTitle = '',
    required this.hinhAnh,
    String? backdropPath,
    required this.diemDanhGia,
    this.voteCount = 0,
    this.releaseDate = '2024-01-01',
    this.runtime = 120,
    this.theLoai = 'Action',
    this.genres = const [],
    this.genreIds = const [],
    required this.moTa,
    this.daoDien = 'Góc Phim',
    int? namPhatHanh,
    String? thoiLuong,
    this.isHot = false,
    this.isNowPlaying = false,
    this.isPopular = false,
    this.isTopRated = false,
    this.isUpcoming = false,
    this.trailerUrl = '',
    this.videoUrl = '',
    this.cast = const [],
    this.yeuThich = false,
  })  : backdropPath = backdropPath ?? hinhAnh,
        _namPhatHanhCustom =
            namPhatHanh ?? (int.tryParse(releaseDate.split('-').first) ?? 2024),
        _thoiLuongCustom = thoiLuong ?? '$runtime phút';

  int get namPhatHanh => _namPhatHanhCustom;
  String get thoiLuong => _thoiLuongCustom;

  factory Movie.fromJson(Map<String, dynamic> json) {
    final genreList =
        (json['genres'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
            [];
    final castList = (json['cast'] as List<dynamic>?)
            ?.map((e) => MovieCastMember.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    final relDate = json['releaseDate']?.toString() ?? '2024-01-01';
    final parsedYear = int.tryParse(relDate.split('-').first) ?? 2024;
    final runTime = json['runtime'] ?? 120;

    return Movie(
      id: json['id'] ?? 0,
      tenPhim: json['title'] ?? json['tenPhim'] ?? '',
      originalTitle: json['originalTitle'] ?? '',
      hinhAnh: json['posterPath'] ?? json['hinhAnh'] ?? '',
      backdropPath: json['backdropPath'] ?? json['posterPath'] ?? '',
      diemDanhGia:
          (json['voteAverage'] ?? json['diemDanhGia'] ?? 0.0).toDouble(),
      voteCount: json['voteCount'] ?? 0,
      releaseDate: relDate,
      runtime: runTime,
      theLoai: genreList.isNotEmpty
          ? genreList.first
          : (json['theLoai'] ?? 'Action'),
      genres: genreList,
      moTa: json['overview'] ?? json['moTa'] ?? '',
      daoDien: json['daoDien'] ?? 'Góc Phim',
      namPhatHanh: json['namPhatHanh'] ?? parsedYear,
      thoiLuong: json['thoiLuong'] ?? '$runTime phút',
      isHot: json['isHot'] ?? false,
      isNowPlaying: json['isNowPlaying'] ?? false,
      isPopular: json['isPopular'] ?? false,
      isTopRated: json['isTopRated'] ?? false,
      isUpcoming: json['isUpcoming'] ?? false,
      trailerUrl: json['trailerUrl'] ?? '',
      videoUrl: json['videoUrl'] ?? '',
      cast: castList,
      yeuThich: json['yeuThich'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': tenPhim,
        'originalTitle': originalTitle,
        'posterPath': hinhAnh,
        'backdropPath': backdropPath,
        'voteAverage': diemDanhGia,
        'voteCount': voteCount,
        'releaseDate': releaseDate,
        'runtime': runtime,
        'genres': genres,
        'overview': moTa,
        'daoDien': daoDien,
        'namPhatHanh': namPhatHanh,
        'thoiLuong': thoiLuong,
        'isHot': isHot,
        'isNowPlaying': isNowPlaying,
        'isPopular': isPopular,
        'isTopRated': isTopRated,
        'isUpcoming': isUpcoming,
        'trailerUrl': trailerUrl,
        'videoUrl': videoUrl,
        'cast': cast.map((e) => e.toJson()).toList(),
        'yeuThich': yeuThich,
      };

  Movie copyWith({
    int? id,
    String? tenPhim,
    String? originalTitle,
    String? hinhAnh,
    String? backdropPath,
    double? diemDanhGia,
    int? voteCount,
    String? releaseDate,
    int? runtime,
    String? theLoai,
    List<String>? genres,
    String? moTa,
    String? daoDien,
    int? namPhatHanh,
    String? thoiLuong,
    bool? isHot,
    bool? isNowPlaying,
    bool? isPopular,
    bool? isTopRated,
    bool? isUpcoming,
    String? trailerUrl,
    String? videoUrl,
    List<MovieCastMember>? cast,
    bool? yeuThich,
  }) {
    return Movie(
      id: id ?? this.id,
      tenPhim: tenPhim ?? this.tenPhim,
      originalTitle: originalTitle ?? this.originalTitle,
      hinhAnh: hinhAnh ?? this.hinhAnh,
      backdropPath: backdropPath ?? this.backdropPath,
      diemDanhGia: diemDanhGia ?? this.diemDanhGia,
      voteCount: voteCount ?? this.voteCount,
      releaseDate: releaseDate ?? this.releaseDate,
      runtime: runtime ?? this.runtime,
      theLoai: theLoai ?? this.theLoai,
      genres: genres ?? this.genres,
      moTa: moTa ?? this.moTa,
      daoDien: daoDien ?? this.daoDien,
      namPhatHanh: namPhatHanh ?? this.namPhatHanh,
      thoiLuong: thoiLuong ?? this.thoiLuong,
      isHot: isHot ?? this.isHot,
      isNowPlaying: isNowPlaying ?? this.isNowPlaying,
      isPopular: isPopular ?? this.isPopular,
      isTopRated: isTopRated ?? this.isTopRated,
      isUpcoming: isUpcoming ?? this.isUpcoming,
      trailerUrl: trailerUrl ?? this.trailerUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      cast: cast ?? this.cast,
      yeuThich: yeuThich ?? this.yeuThich,
    );
  }

  @override
  List<Object?> get props => [
        id,
        tenPhim,
        originalTitle,
        hinhAnh,
        backdropPath,
        diemDanhGia,
        voteCount,
        releaseDate,
        runtime,
        theLoai,
        genres,
        moTa,
        daoDien,
        _namPhatHanhCustom,
        _thoiLuongCustom,
        isHot,
        isNowPlaying,
        isPopular,
        isTopRated,
        isUpcoming,
        trailerUrl,
        videoUrl,
        cast,
        yeuThich,
      ];
}
