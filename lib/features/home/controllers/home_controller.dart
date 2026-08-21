import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/movie.dart';
import '../../actor/models/actor.dart';
import '../../profile/data/user_profile_manager.dart';

class HomeController extends ChangeNotifier {
  static const String _legacyFavIdsKey = 'favorite_movie_ids';
  static const String _legacyFavMoviesKey = 'favorite_movies_json';
  String _currentUserKey = 'favorites_guest';

  //==========================================================
  // Singleton
  //==========================================================

  HomeController._();

  static final HomeController instance = HomeController._();

  final List<Movie> danhSachPhim = [];
  final List<Actor> danhSachDienVien = [];
  final Set<int> favoriteMovieIds = {};
  bool _isInitialized = false;

  void clearFavorites() {
    favoriteMovieIds.clear();
    for (var m in danhSachPhim) {
      m.yeuThich = false;
    }
    _saveFavorites();
    notifyListeners();
  }

  String _getKeyForUser([String? emailOrId]) {
    if (emailOrId != null && emailOrId.isNotEmpty) {
      return 'favorites_${emailOrId.toLowerCase()}';
    }
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null && user.id.isNotEmpty) {
        return 'favorites_${user.id}';
      }
    } catch (_) {}
    final email = UserProfileManager.instance.profile.value.email;
    if (email.isNotEmpty) {
      return 'favorites_${email.toLowerCase()}';
    }
    return 'favorites_guest';
  }

  Future<void> loadForUser([String? emailOrId]) async {
    _currentUserKey = _getKeyForUser(emailOrId);
    await _loadSavedFavorites();
  }

  Future<void> init() async {
    if (_isInitialized && danhSachPhim.isNotEmpty) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_legacyFavIdsKey);
      await prefs.remove(_legacyFavMoviesKey);
    } catch (_) {}

    try {
      final moviesStr = await rootBundle.loadString('assets/json/movies.json');
      final List<dynamic> moviesJson = json.decode(moviesStr);
      danhSachPhim.clear();
      for (final item in moviesJson) {
        final movie = Movie.fromJson(item as Map<String, dynamic>);
        movie.yeuThich = false;
        danhSachPhim.add(movie);
      }
    } catch (_) {
      _loadFallbackMovies();
    }

    try {
      final actorsStr = await rootBundle.loadString('assets/json/actors.json');
      final List<dynamic> actorsJson = json.decode(actorsStr);
      danhSachDienVien.clear();
      for (final item in actorsJson) {
        danhSachDienVien.add(Actor.fromJson(item as Map<String, dynamic>));
      }
    } catch (_) {
      _loadFallbackActors();
    }

    await _loadSavedFavorites();

    _isInitialized = true;
  }

  Future<void> _loadSavedFavorites() async {
    favoriteMovieIds.clear();
    for (var m in danhSachPhim) {
      m.yeuThich = false;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? savedIds =
          prefs.getStringList('${_currentUserKey}_ids');
      if (savedIds != null && savedIds.isNotEmpty) {
        favoriteMovieIds.addAll(
          savedIds.map((e) => int.tryParse(e) ?? 0).where((id) => id != 0),
        );
      }

      final String? savedMoviesStr =
          prefs.getString('${_currentUserKey}_movies');
      if (savedMoviesStr != null && savedMoviesStr.isNotEmpty) {
        final List<dynamic> listJson = jsonDecode(savedMoviesStr);
        for (final item in listJson) {
          final favMovie = Movie.fromJson(item as Map<String, dynamic>);
          favMovie.yeuThich = true;
          favoriteMovieIds.add(favMovie.id);

          final idx = danhSachPhim.indexWhere((m) => m.id == favMovie.id);
          if (idx != -1) {
            danhSachPhim[idx].yeuThich = true;
          } else {
            danhSachPhim.add(favMovie);
          }
        }
      }

      for (final m in danhSachPhim) {
        if (favoriteMovieIds.contains(m.id)) {
          m.yeuThich = true;
        }
      }
    } catch (_) {}
    notifyListeners();
  }

  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        '${_currentUserKey}_ids',
        favoriteMovieIds.map((id) => id.toString()).toList(),
      );

      final favMovies = danhSachPhim
          .where((m) => m.yeuThich || favoriteMovieIds.contains(m.id))
          .toList();
      final String jsonStr =
          jsonEncode(favMovies.map((m) => m.toJson()).toList());
      await prefs.setString('${_currentUserKey}_movies', jsonStr);
    } catch (_) {}
  }

  void _loadFallbackMovies() {
    danhSachPhim.clear();
    danhSachPhim.addAll([
      Movie(
        id: 1,
        tenPhim: "Dune: Hành Tinh Cát - Phần Two",
        originalTitle: "Dune: Part Two",
        hinhAnh: "assets/images/dune2.jpg",
        backdropPath: "assets/images/dune2.jpg",
        diemDanhGia: 8.7,
        theLoai: "Khoa học viễn tưởng",
        moTa:
            "Paul Atreides hợp lực cùng Chani và người Fremen để trả thù những kẻ đã hủy hoại gia đình anh.",
        isHot: true,
        isNowPlaying: true,
        isPopular: true,
        isTopRated: true,
        trailerUrl: "https://www.youtube.com/watch?v=Way9Dexny3w",
        yeuThich: false,
      ),
      Movie(
        id: 2,
        tenPhim: "Oppenheimer",
        originalTitle: "Oppenheimer",
        hinhAnh: "assets/images/oppenheimer.jpg",
        backdropPath: "assets/images/oppenheimer.jpg",
        diemDanhGia: 8.9,
        theLoai: "Lịch sử • Chính kịch",
        moTa:
            "Câu chuyện về nhà vật lý lý thuyết J. Robert Oppenheimer chế tạo bom nguyên tử.",
        isHot: true,
        isPopular: true,
        isTopRated: true,
        trailerUrl: "https://www.youtube.com/watch?v=uYPbbksJxIg",
        yeuThich: false,
      ),
      Movie(
        id: 3,
        tenPhim: "Deadpool & Wolverine",
        originalTitle: "Deadpool & Wolverine",
        hinhAnh: "assets/images/deadpool.jpg",
        backdropPath: "assets/images/deadpool.jpg",
        diemDanhGia: 8.4,
        theLoai: "Hành động • Hài hước",
        moTa: "Wolverine hợp tác với Deadpool láu cá để giải cứu vũ trụ.",
        isHot: true,
        isNowPlaying: true,
        isPopular: true,
        trailerUrl: "https://www.youtube.com/watch?v=73_1biulkYk",
        yeuThich: false,
      ),
    ]);
  }

  void _loadFallbackActors() {
    danhSachDienVien.clear();
    danhSachDienVien.addAll([
      const Actor(
        id: 101,
        name: "Timothée Chalamet",
        profilePath: "assets/images/actor_1.jpg",
        biography:
            "Timothée Chalamet là nam diễn viên xuất sắc từng nhận đề cử giải Oscar.",
        birthday: "1995-12-27",
        placeOfBirth: "New York, USA",
        knownFor: [
          KnownMovie(
              id: 1,
              title: "Dune: Part Two",
              posterPath: "assets/images/dune2.jpg"),
        ],
      ),
      const Actor(
        id: 102,
        name: "Zendaya",
        profilePath: "assets/images/actor_2.jpg",
        biography:
            "Zendaya là nữ diễn viên, ca sĩ nổi tiếng đoạt nhiều giải Emmy.",
        birthday: "1996-09-01",
        placeOfBirth: "Oakland, California, USA",
        knownFor: [
          KnownMovie(
              id: 1,
              title: "Dune: Part Two",
              posterPath: "assets/images/dune2.jpg"),
        ],
      ),
    ]);
  }

  //==========================================================
  // Phân loại danh sách phim
  //==========================================================

  List<Movie> get danhSachPhimHot {
    return danhSachPhim.where((m) => m.isHot).toList();
  }

  List<Movie> get danhSachPhimDangChieu {
    final list = danhSachPhim.where((m) => m.isNowPlaying).toList();
    return list.isNotEmpty ? list : danhSachPhim.take(4).toList();
  }

  List<Movie> get danhSachPhimPhoBien {
    final list = danhSachPhim.where((m) => m.isPopular).toList();
    return list.isNotEmpty ? list : danhSachPhim.take(5).toList();
  }

  List<Movie> get danhSachPhimDanhGiaCao {
    final list = danhSachPhim.where((m) => m.isTopRated).toList();
    return list.isNotEmpty ? list : danhSachPhim.take(4).toList();
  }

  List<Movie> get danhSachPhimSapChieu {
    final list = danhSachPhim.where((m) => m.isUpcoming).toList();
    if (list.isNotEmpty) return list;
    final nowPlayingIds = danhSachPhimDangChieu.map((m) => m.id).toSet();
    return danhSachPhim
        .where((m) => !nowPlayingIds.contains(m.id))
        .take(4)
        .toList();
  }

  //==========================================================
  // Danh sách Yêu thích
  //==========================================================

  List<Movie> get danhSachYeuThich {
    return danhSachPhim.where((movie) => movie.yeuThich).toList();
  }

  void doiTrangThaiYeuThich(Movie movie) {
    capNhatTrangThaiYeuThich(movie, !movie.yeuThich);
  }

  void capNhatTrangThaiYeuThich(Movie movie, bool yeuThich) {
    movie.yeuThich = yeuThich;
    if (yeuThich) {
      favoriteMovieIds.add(movie.id);
    } else {
      favoriteMovieIds.remove(movie.id);
    }
    for (var m in danhSachPhim) {
      if (m.id == movie.id) {
        m.yeuThich = yeuThich;
      }
    }
    if (yeuThich && !danhSachPhim.any((m) => m.id == movie.id)) {
      danhSachPhim.add(movie);
    }
    _saveFavorites();
    notifyListeners();
  }

  //==========================================================
  // Lấy chi tiết Phim
  //==========================================================

  Movie? getMovieById(int movieId) {
    try {
      return danhSachPhim.firstWhere((m) => m.id == movieId);
    } catch (_) {
      return null;
    }
  }

  //==========================================================
  // Lấy chi tiết Diễn viên
  //==========================================================

  Actor? getActorById(int actorId) {
    try {
      return danhSachDienVien.firstWhere((a) => a.id == actorId);
    } catch (_) {
      if (danhSachDienVien.isNotEmpty) return danhSachDienVien.first;
      return null;
    }
  }

  //==========================================================
  // Tìm kiếm
  //==========================================================

  List<Movie> timKiemPhim(String keyword) {
    if (keyword.trim().isEmpty) return danhSachPhim;
    final query = keyword.toLowerCase();
    return danhSachPhim.where((movie) {
      return movie.tenPhim.toLowerCase().contains(query) ||
          movie.originalTitle.toLowerCase().contains(query) ||
          movie.theLoai.toLowerCase().contains(query);
    }).toList();
  }
}
