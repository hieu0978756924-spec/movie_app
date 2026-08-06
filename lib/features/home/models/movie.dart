import 'package:equatable/equatable.dart';

// ignore: must_be_immutable
class Movie extends Equatable {
  final int id;
  final String tenPhim;
  final String hinhAnh;
  final String? backdropPath;
  final double diemDanhGia;
  final String theLoai;
  final String thoiLuong;
  final String moTa;
  final int namPhatHanh;
  final String daoDien;
  final List<int> genreIds;
  final int voteCount;
  bool yeuThich;

  Movie({
    this.id = 0,
    required this.tenPhim,
    required this.hinhAnh,
    this.backdropPath,
    required this.diemDanhGia,
    this.theLoai = 'Action',
    this.thoiLuong = '120 min',
    required this.moTa,
    this.namPhatHanh = 2026,
    this.daoDien = 'Góc Phim',
    this.genreIds = const [],
    this.voteCount = 0,
    this.yeuThich = false,
  });

  Movie copyWith({
    int? id,
    String? tenPhim,
    String? hinhAnh,
    String? backdropPath,
    double? diemDanhGia,
    String? theLoai,
    String? thoiLuong,
    String? moTa,
    int? namPhatHanh,
    String? daoDien,
    List<int>? genreIds,
    int? voteCount,
    bool? yeuThich,
  }) {
    return Movie(
      id: id ?? this.id,
      tenPhim: tenPhim ?? this.tenPhim,
      hinhAnh: hinhAnh ?? this.hinhAnh,
      backdropPath: backdropPath ?? this.backdropPath,
      diemDanhGia: diemDanhGia ?? this.diemDanhGia,
      theLoai: theLoai ?? this.theLoai,
      thoiLuong: thoiLuong ?? this.thoiLuong,
      moTa: moTa ?? this.moTa,
      namPhatHanh: namPhatHanh ?? this.namPhatHanh,
      daoDien: daoDien ?? this.daoDien,
      genreIds: genreIds ?? this.genreIds,
      voteCount: voteCount ?? this.voteCount,
      yeuThich: yeuThich ?? this.yeuThich,
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
        thoiLuong,
        moTa,
        namPhatHanh,
        daoDien,
        genreIds,
        voteCount,
        yeuThich,
      ];
}