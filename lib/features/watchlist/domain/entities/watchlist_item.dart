import 'package:equatable/equatable.dart';

class WatchlistItem extends Equatable {
  final int id;
  final String tenPhim;
  final String hinhAnh;
  final String? backdropPath;
  final double diemDanhGia;
  final String theLoai;
  final int namPhatHanh;
  final bool daXem;
  final DateTime addedAt;

  const WatchlistItem({
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

  WatchlistItem copyWith({
    int? id,
    String? tenPhim,
    String? hinhAnh,
    String? backdropPath,
    double? diemDanhGia,
    String? theLoai,
    int? namPhatHanh,
    bool? daXem,
    DateTime? addedAt,
  }) {
    return WatchlistItem(
      id: id ?? this.id,
      tenPhim: tenPhim ?? this.tenPhim,
      hinhAnh: hinhAnh ?? this.hinhAnh,
      backdropPath: backdropPath ?? this.backdropPath,
      diemDanhGia: diemDanhGia ?? this.diemDanhGia,
      theLoai: theLoai ?? this.theLoai,
      namPhatHanh: namPhatHanh ?? this.namPhatHanh,
      daXem: daXem ?? this.daXem,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        tenPhim,
        hinhAnh,
        backdropPath,
        diemDanhGia,
        theLoai,
        namPhatHanh,
        daXem,
        addedAt,
      ];
}
