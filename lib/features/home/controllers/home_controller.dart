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
      id: 693134,
      tenPhim: "Dune: Part Two",
      hinhAnh: "assets/images/dune2.jpg",
      backdropPath: "/xOMo8ScRjWyZJPZQuexSTtS2JeE.jpg",
      diemDanhGia: 4.9,
      theLoai: "Khoa học viễn tưởng • Hành động",
      thoiLuong: "2 giờ 46 phút",
      moTa:
          "Paul Atreides tái hợp với Chani và người Fremen khi anh tìm kiếm sự trả thù những kẻ âm mưu hủy hoại gia đình mình.",
      namPhatHanh: 2024,
      daoDien: "Denis Villeneuve",
    ),

    Movie(
      id: 872585,
      tenPhim: "Oppenheimer",
      hinhAnh: "assets/images/oppenheimer.jpg",
      backdropPath: "/fm6KqXrmjM2pvrmNV3hDrm2O6Yy.jpg",
      diemDanhGia: 4.8,
      theLoai: "Lịch sử • Chính kịch",
      thoiLuong: "3 giờ 0 phút",
      moTa:
          "Câu chuyện về nhà vật lý lý thuyết J. Robert Oppenheimer và quá trình chế tạo bom nguyên tử.",
      namPhatHanh: 2023,
      daoDien: "Christopher Nolan",
    ),

    Movie(
      id: 533535,
      tenPhim: "Deadpool & Wolverine",
      hinhAnh: "assets/images/deadpool.jpg",
      backdropPath: "assets/images/deadpool.jpg",
      diemDanhGia: 4.8,
      theLoai: "Hành động • Marvel",
      thoiLuong: "2 giờ 8 phút",
      moTa:
          "Wolverine đang hồi phục chấn thương thì gặp phải Deadpool lắm chiêu.",
      namPhatHanh: 2024,
      daoDien: "Shawn Levy",
    ),

    Movie(
      id: 299534,
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
      id: 634649,
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
      id: 76600,
      tenPhim: "Avatar 2",
      hinhAnh: "assets/images/avatar_movie.jpg",
      diemDanhGia: 4.8,
      theLoai: "Khoa học viễn tưởng",
      thoiLuong: "3 giờ 12 phút",
      moTa:
          "Hành trình tiếp theo của gia đình Jake Sully trên hành tinh Pandora.",
      namPhatHanh: 2022,
      daoDien: "James Cameron",
    ),

    Movie(
      id: 475557,
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
      id: 1011985,
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

    Movie(
      id: 1022789,
      tenPhim: "Inside Out 2",
      hinhAnh: "assets/images/insideout2.jpg",
      backdropPath: "/stKGOm8UyhuLPR92pNJhYjWwRiy.jpg",
      diemDanhGia: 4.8,
      theLoai: "Hoạt hình • Gia đình",
      thoiLuong: "1 giờ 36 phút",
      moTa:
          "Riley bước vào tuổi dậy thì với những cảm xúc hoàn toàn mới mẻ như Lo Âu, Ghen Tị và Xấu Hổ.",
      namPhatHanh: 2024,
      daoDien: "Kelsey Mann",
    ),

    Movie(
      id: 414906,
      tenPhim: "The Batman",
      hinhAnh: "assets/images/batman.jpg",
      backdropPath: "/b0PlSFdUZSZrFj2v9ICelBuL31L.jpg",
      diemDanhGia: 4.8,
      theLoai: "Hành động • Tội phạm",
      thoiLuong: "2 giờ 56 phút",
      moTa:
          "Bruce Wayne điều tra các vụ án bí ẩn tại thành phố Gotham và đối đầu với tên tội phạm Riddler.",
      namPhatHanh: 2022,
      daoDien: "Matt Reeves",
    ),

    Movie(
      id: 361743,
      tenPhim: "Top Gun: Maverick",
      hinhAnh: "assets/images/banner.jpg",
      backdropPath: "/AaV1YIdWKnjAydBx85HCm25LBw2.jpg",
      diemDanhGia: 4.9,
      theLoai: "Hành động • Phiêu lưu",
      thoiLuong: "2 giờ 11 phút",
      moTa:
          "Maverick trở lại trường huấn luyện phi công Top Gun để dẫn dắt đội ngũ phi công trẻ thực hiện nhiệm vụ nguy hiểm.",
      namPhatHanh: 2022,
      daoDien: "Joseph Kosinski",
    ),

    Movie(
      id: 157336,
      tenPhim: "Interstellar",
      hinhAnh: "assets/images/interstellar.jpg",
      backdropPath: "/xJHokMbljvjADYdit5fKjVQsXvh.jpg",
      diemDanhGia: 4.9,
      theLoai: "Khoa học viễn tưởng • Phiêu lưu",
      thoiLuong: "2 giờ 49 phút",
      moTa:
          "Một nhóm nhà nghiên cứu du hành qua hố đen vũ trụ để tìm kiếm hành tinh mới cho nhân loại.",
      namPhatHanh: 2014,
      daoDien: "Christopher Nolan",
    ),

    Movie(
      id: 558449,
      tenPhim: "Gladiator II",
      hinhAnh: "assets/images/gladiator2.jpg",
      backdropPath: "/euYIwmwWdoBDVDoLEwuC9LwoMCB.jpg",
      diemDanhGia: 4.7,
      theLoai: "Hành động • Lịch sử",
      thoiLuong: "2 giờ 28 phút",
      moTa:
          "Lucius bước vào Đấu trường La Mã để đấu tranh phục hồi vinh quang cho Rome.",
      namPhatHanh: 2024,
      daoDien: "Ridley Scott",
    ),

    Movie(
      id: 786892,
      tenPhim: "Furiosa: A Mad Max Saga",
      hinhAnh: "assets/images/furiosa.jpg",
      backdropPath: "/wNAhuOZfiQjB2atioiohA976OF2.jpg",
      diemDanhGia: 4.7,
      theLoai: "Hành động • Khoa học viễn tưởng",
      thoiLuong: "2 giờ 28 phút",
      moTa:
          "Hành trình của Furiosa trẻ tuổi vượt qua sa mạc khắc nghiệt để bảo vệ quê hương.",
      namPhatHanh: 2024,
      daoDien: "George Miller",
    ),

    Movie(
      id: 572802,
      tenPhim: "Aquaman and the Lost Kingdom",
      hinhAnh: "assets/images/aquaman2.jpg",
      backdropPath: "/cn9d56xGlnC1d120W2p5bC6u8.jpg",
      diemDanhGia: 4.6,
      theLoai: "Hành động • Viễn tưởng",
      thoiLuong: "2 giờ 4 phút",
      moTa:
          "Arthur Curry hợp tác với em trai Orm để bảo vệ vương quốc Atlantis khỏi mối đe dọa từ Black Manta.",
      namPhatHanh: 2023,
      daoDien: "James Wan",
    ),


    Movie(
      id: 575264,
      tenPhim: "Mission: Impossible - Dead Reckoning",
      hinhAnh: "assets/images/mission_impossible.jpg",
      backdropPath: "/628OS2ipeL2of6cW9v9LMBa32wb.jpg",
      diemDanhGia: 4.8,
      theLoai: "Hành động • Tình báo",
      thoiLuong: "2 giờ 43 phút",
      moTa:
          "Ethan Hunt và đội IMF thực hiện nhiệm vụ nguy hiểm nhất để ngăn chặn một trí tuệ nhân tạo toàn năng.",
      namPhatHanh: 2023,
      daoDien: "Christopher McQuarrie",
    ),

    Movie(
      id: 385687,
      tenPhim: "Fast X",
      hinhAnh: "assets/images/fastx.jpg",
      backdropPath: "/4XM82xNS8KHkRxGFCfV2D2K42V.jpg",
      diemDanhGia: 4.7,
      theLoai: "Hành động • Tốc độ",
      thoiLuong: "2 giờ 21 phút",
      moTa:
          "Dom Toretto đối đầu với kẻ thù nguy hiểm Dante Reyes muốn trả thù cho gia đình.",
      namPhatHanh: 2023,
      daoDien: "Louis Leterrier",
    ),

    Movie(
      id: 698687,
      tenPhim: "Transformers: One",
      hinhAnh: "assets/images/transformers.jpg",
      backdropPath: "/uKb22SF9uGlv4Z24x26eyRooYp.jpg",
      diemDanhGia: 4.8,
      theLoai: "Hoạt hình • Hành động",
      thoiLuong: "1 giờ 44 phút",
      moTa:
          "Câu chuyện chưa từng kể về tình bạn và mối thù giữa Orion Pax (Optimus Prime) và D-16 (Megatron).",
      namPhatHanh: 2024,
      daoDien: "Josh Cooley",
    ),
  ];

  //==========================================================
  // Phân loại danh sách phim cho từng mục
  //==========================================================

  List<Movie> get danhSachPhimDangChieu {
    const ids = [693134, 533535, 1022789, 1011985];
    return danhSachPhim.where((m) => ids.contains(m.id)).toList();
  }

  List<Movie> get danhSachPhimPhoBien {
    const ids = [872585, 634649, 414906, 361743, 299534];
    return danhSachPhim.where((m) => ids.contains(m.id)).toList();
  }

  List<Movie> get danhSachPhimDanhGiaCao {
    const ids = [157336, 475557, 693134, 872585];
    return danhSachPhim.where((m) => ids.contains(m.id)).toList();
  }

  List<Movie> get danhSachPhimSapChieu {
    const ids = [558449, 786892, 572802, 76600, 698687];
    return danhSachPhim.where((m) => ids.contains(m.id)).toList();
  }

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
    capNhatTrangThaiYeuThich(movie, movie.yeuThich);
  }

  void capNhatTrangThaiYeuThich(Movie movie, bool yeuThich) {
    movie.yeuThich = yeuThich;
    final index = danhSachPhim.indexWhere((m) => m.id == movie.id);
    if (index != -1) {
      danhSachPhim[index].yeuThich = yeuThich;
    } else if (yeuThich) {
      danhSachPhim.add(movie);
    }
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