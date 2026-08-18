import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:movie_app/features/home/models/movie.dart';
import 'package:movie_app/features/profile/data/watch_history_manager.dart';
import 'package:movie_app/features/profile/views/watched_videos_view.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    WatchHistoryManager.instance.history.value = [
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
    ];
  });
  testWidgets('WatchedVideosView renders watched video items correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: WatchedVideosView(),
      ),
    );

    // Verify Title
    expect(find.text('Video đã xem'), findsOneWidget);

    // Verify movie items in watch history
    expect(find.text('Dune: Hành Tinh Cát - Phần Hai'), findsOneWidget);
    expect(find.text('Oppenheimer'), findsOneWidget);
    expect(find.text('Deadpool & Wolverine'), findsOneWidget);

    // Verify progress text
    expect(find.text('Đã xem 85%'), findsOneWidget);
    expect(find.text('Đã xem 100%'), findsOneWidget);
    expect(find.text('Đã xem 45%'), findsOneWidget);
  });

  testWidgets('Can delete item from watched history', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: WatchedVideosView(),
      ),
    );

    // Initial count
    expect(WatchHistoryManager.instance.history.value.length, 3);

    // Remove first item
    WatchHistoryManager.instance.removeItemAt(0);
    await tester.pumpAndSettle();

    expect(WatchHistoryManager.instance.history.value.length, 2);
    expect(find.text('Dune: Hành Tinh Cát - Phần Hai'), findsNothing);
  });
}
