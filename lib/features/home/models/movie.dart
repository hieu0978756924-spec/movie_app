class Movie {
  //================ THÔNG TIN PHIM ================//

  /// Tên phim
  final String tenPhim;

  /// Đường dẫn hình ảnh
  final String hinhAnh;

  /// Điểm đánh giá
  final double diemDanhGia;

  /// Thể loại
  final String theLoai;

  /// Thời lượng
  final String thoiLuong;

  /// Nội dung phim
  final String moTa;

  /// Năm phát hành
  final int namPhatHanh;

  /// Đạo diễn
  final String daoDien;
 

  /// Trạng thái yêu thích
  bool yeuThich;

  Movie({
    required this.tenPhim,
    required this.hinhAnh,
    required this.diemDanhGia,
    required this.theLoai,
    required this.thoiLuong,
    required this.moTa,
    required this.namPhatHanh,
    required this.daoDien,
    this.yeuThich = false,
  });
}