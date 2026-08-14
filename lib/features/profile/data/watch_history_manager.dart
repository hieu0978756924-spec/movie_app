import 'package:flutter/foundation.dart';
import '../../home/models/movie.dart';

class WatchedVideoItem {
  final Movie movie;
  final String watchedAt;
  final double progress; // 0.0 to 1.0

  const WatchedVideoItem({
    required this.movie,
    required this.watchedAt,
    required this.progress,
  });
}

class WatchHistoryManager {
  WatchHistoryManager._internal() {
    history = ValueNotifier<List<WatchedVideoItem>>([
      WatchedVideoItem(
        movie: Movie(
          id: 693134,
          tenPhim: 'Dune: Hành Tinh Cát - Phần Hai',
          hinhAnh: 'assets/images/dune2.jpg',
          backdropPath: 'assets/images/dune2.jpg',
          diemDanhGia: 4.3,
          theLoai: 'Khoa học viễn tưởng',
          thoiLuong: '166 min',
          moTa: 'Hành trình trả thù và bảo vệ vũ trụ của Paul Atreides.',
          namPhatHanh: 2024,
          daoDien: 'Denis Villeneuve',
        ),
        watchedAt: 'Hôm nay, 14:30',
        progress: 0.85,
      ),
      WatchedVideoItem(
        movie: Movie(
          id: 872585,
          tenPhim: 'Oppenheimer',
          hinhAnh: 'assets/images/oppenheimer.jpg',
          backdropPath: 'assets/images/oppenheimer.jpg',
          diemDanhGia: 4.5,
          theLoai: 'Tâm lý, Lịch sử',
          thoiLuong: '180 min',
          moTa: 'Câu chuyện về cuộc đời của nhà vật lý J. Robert Oppenheimer.',
          namPhatHanh: 2023,
          daoDien: 'Christopher Nolan',
        ),
        watchedAt: 'Hôm qua, 20:15',
        progress: 1.0,
      ),
      WatchedVideoItem(
        movie: Movie(
          id: 533535,
          tenPhim: 'Deadpool & Wolverine',
          hinhAnh: 'assets/images/deadpool.jpg',
          backdropPath: 'assets/images/deadpool.jpg',
          diemDanhGia: 4.1,
          theLoai: 'Hành động, Hài hước',
          thoiLuong: '127 min',
          moTa: 'Cuộc hội ngộ hài hước và nghẹt thở giữa Deadpool và Wolverine.',
          namPhatHanh: 2024,
          daoDien: 'Shawn Levy',
        ),
        watchedAt: '3 ngày trước',
        progress: 0.45,
      ),
    ]);
  }

  static final WatchHistoryManager instance = WatchHistoryManager._internal();

  late final ValueNotifier<List<WatchedVideoItem>> history;

  void addWatchedVideo(Movie movie, {double progress = 1.0}) {
    final currentList = List<WatchedVideoItem>.from(history.value);
    currentList.removeWhere((item) => item.movie.id == movie.id);
    currentList.insert(
      0,
      WatchedVideoItem(
        movie: movie,
        watchedAt: 'Mới xong',
        progress: progress,
      ),
    );
    history.value = currentList;
  }

  void removeItemAt(int index) {
    if (index >= 0 && index < history.value.length) {
      final currentList = List<WatchedVideoItem>.from(history.value);
      currentList.removeAt(index);
      history.value = currentList;
    }
  }

  void removeItemById(int movieId) {
    final currentList = List<WatchedVideoItem>.from(history.value);
    currentList.removeWhere((item) => item.movie.id == movieId);
    history.value = currentList;
  }

  void clearHistory() {
    history.value = [];
  }
}
