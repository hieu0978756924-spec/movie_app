import '../../domain/entities/watchlist_item.dart';
import '../../../home/models/movie.dart';

class WatchlistItemModel {
  final int id;
  final String tenPhim;
  final String hinhAnh;
  final String? backdropPath;
  final double diemDanhGia;
  final String theLoai;
  final int namPhatHanh;
  final bool daXem;
  final String addedAt;

  const WatchlistItemModel({
    required this.id,
    required this.tenPhim,
    required this.hinhAnh,
    this.backdropPath,
    required this.diemDanhGia,
    this.theLoai = 'Phim',
    this.namPhatHanh = 2026,
    this.daXem = false,
    required this.addedAt,
  });

  factory WatchlistItemModel.fromMap(Map<dynamic, dynamic> map) {
    return WatchlistItemModel(
      id: map['id'] as int? ?? 0,
      tenPhim: map['tenPhim'] as String? ?? '',
      hinhAnh: map['hinhAnh'] as String? ?? '',
      backdropPath: map['backdropPath'] as String?,
      diemDanhGia: (map['diemDanhGia'] as num?)?.toDouble() ?? 0.0,
      theLoai: map['theLoai'] as String? ?? 'Phim',
      namPhatHanh: map['namPhatHanh'] as int? ?? 2026,
      daXem: map['daXem'] as bool? ?? false,
      addedAt: map['addedAt'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tenPhim': tenPhim,
      'hinhAnh': hinhAnh,
      'backdropPath': backdropPath,
      'diemDanhGia': diemDanhGia,
      'theLoai': theLoai,
      'namPhatHanh': namPhatHanh,
      'daXem': daXem,
      'addedAt': addedAt,
    };
  }

  WatchlistItem toEntity() {
    return WatchlistItem(
      id: id,
      tenPhim: tenPhim,
      hinhAnh: hinhAnh,
      backdropPath: backdropPath,
      diemDanhGia: diemDanhGia,
      theLoai: theLoai,
      namPhatHanh: namPhatHanh,
      daXem: daXem,
      addedAt: DateTime.tryParse(addedAt) ?? DateTime.now(),
    );
  }

  factory WatchlistItemModel.fromEntity(WatchlistItem entity) {
    return WatchlistItemModel(
      id: entity.id,
      tenPhim: entity.tenPhim,
      hinhAnh: entity.hinhAnh,
      backdropPath: entity.backdropPath,
      diemDanhGia: entity.diemDanhGia,
      theLoai: entity.theLoai,
      namPhatHanh: entity.namPhatHanh,
      daXem: entity.daXem,
      addedAt: entity.addedAt.toIso8601String(),
    );
  }

  factory WatchlistItemModel.fromMovie(Movie movie, {bool daXem = false}) {
    return WatchlistItemModel(
      id: movie.id,
      tenPhim: movie.tenPhim,
      hinhAnh: movie.hinhAnh,
      backdropPath: movie.backdropPath,
      diemDanhGia: movie.diemDanhGia,
      theLoai: movie.theLoai,
      namPhatHanh: movie.namPhatHanh,
      daXem: daXem,
      addedAt: DateTime.now().toIso8601String(),
    );
  }
}
