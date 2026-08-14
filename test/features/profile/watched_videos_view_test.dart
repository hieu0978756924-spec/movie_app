import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/features/profile/data/watch_history_manager.dart';
import 'package:movie_app/features/profile/views/watched_videos_view.dart';

void main() {
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
