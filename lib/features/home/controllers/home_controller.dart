import '../models/movie.dart';

class HomeController {
  //==========================================================
  // Singleton
  //==========================================================

  HomeController._();

  static final HomeController instance = HomeController._();

  //==========================================================
  // Danh sách phim
  //==========================================================

  final List<Movie> danhSachPhim = [

    Movie(
      tenPhim: "Lật Mặt 7",
      hinhAnh: "assets/images/latmat7.jpg",
      diemDanhGia: 4.8,
      theLoai: "Tâm lý • Gia đình",
      thoiLuong: "2 giờ 5 phút",
      moTa:
          "Một bộ phim cảm động về tình cảm gia đình và tình mẫu tử.",
      namPhatHanh: 2024,
      daoDien: "Lý Hải",
    ),

    Movie(
      tenPhim: "Mai",
      hinhAnh: "assets/images/mai.jpg",
      diemDanhGia: 4.9,
      theLoai: "Tình cảm",
      thoiLuong: "2 giờ 11 phút",
      moTa:
          "Bộ phim điện ảnh nổi bật của Trấn Thành với câu chuyện đầy cảm xúc.",
      namPhatHanh: 2024,
      daoDien: "Trấn Thành",
    ),

    Movie(
      tenPhim: "Nhà Bà Nữ",
      hinhAnh: "assets/images/nhabanu.jpg",
      diemDanhGia: 4.7,
      theLoai: "Gia đình",
      thoiLuong: "1 giờ 45 phút",
      moTa:
          "Câu chuyện về gia đình, tình yêu và những mâu thuẫn trong cuộc sống.",
      namPhatHanh: 2023,
      daoDien: "Trấn Thành",
    ),

    Movie(
      tenPhim: "Avengers: Endgame",
      hinhAnh: "assets/images/endgame.jpg",
      diemDanhGia: 5.0,
      theLoai: "Hành động • Marvel",
      thoiLuong: "3 giờ 2 phút",
      moTa:
          "Cuộc chiến cuối cùng của các siêu anh hùng chống lại Thanos.",
      namPhatHanh: 2019,
      daoDien: "Anthony Russo",
    ),

    Movie(
      tenPhim: "Spider-Man",
      hinhAnh: "assets/images/spiderman.jpg",
      diemDanhGia: 4.8,
      theLoai: "Marvel",
      thoiLuong: "2 giờ 20 phút",
      moTa:
          "Peter Parker đối đầu với những thử thách mới sau khi danh tính bị lộ.",
      namPhatHanh: 2021,
      daoDien: "Jon Watts",
    ),

    Movie(
      tenPhim: "Avatar 2",
      hinhAnh: "assets/images/avatar2.jpg",
      diemDanhGia: 4.8,
      theLoai: "Khoa học viễn tưởng",
      thoiLuong: "3 giờ 12 phút",
      moTa:
          "Hành trình tiếp theo của gia đình Jake Sully trên hành tinh Pandora.",
      namPhatHanh: 2022,
      daoDien: "James Cameron",
    ),

    Movie(
      tenPhim: "Joker",
      hinhAnh: "assets/images/joker.jpg",
      diemDanhGia: 4.9,
      theLoai: "Tâm lý",
      thoiLuong: "2 giờ 2 phút",
      moTa:
          "Sự biến đổi của Arthur Fleck trở thành Joker khét tiếng.",
      namPhatHanh: 2019,
      daoDien: "Todd Phillips",
    ),

    Movie(
      tenPhim: "Kung Fu Panda 4",
      hinhAnh: "assets/images/panda4.jpg",
      diemDanhGia: 4.6,
      theLoai: "Hoạt hình",
      thoiLuong: "1 giờ 35 phút",
      moTa:
          "Po tiếp tục hành trình bảo vệ Thung lũng Bình Yên.",
      namPhatHanh: 2024,
      daoDien: "Mike Mitchell",
    ),
  ];

  //==========================================================
  // Lấy danh sách phim yêu thích
  //==========================================================

  List<Movie> get danhSachYeuThich {
    return danhSachPhim
        .where((movie) => movie.yeuThich)
        .toList();
  }

  //==========================================================
  // Đổi trạng thái yêu thích
  //==========================================================

  void doiTrangThaiYeuThich(Movie movie) {
    movie.yeuThich = !movie.yeuThich;
  }

  //==========================================================
  // Tìm kiếm phim
  //==========================================================

  List<Movie> timKiemPhim(String keyword) {
    if (keyword.isEmpty) {
      return danhSachPhim;
    }

    return danhSachPhim.where((movie) {
      return movie.tenPhim
          .toLowerCase()
          .contains(keyword.toLowerCase());
    }).toList();
  }
}