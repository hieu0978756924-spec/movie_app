import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/features/profile/views/profile_view.dart';

void main() {
  testWidgets('ProfileView renders Stitch UI layout and options correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ProfileView(),
      ),
    );

    // Verify Title
    expect(find.text('Tài Khoản'), findsOneWidget);

    // Verify user name, VIP badge and email are present
    expect(find.text('Nguyễn Ngọc Như Hiếu'), findsOneWidget);
    expect(find.text('VIP'), findsOneWidget);
    expect(find.text('nhuhieu@gmail.com'), findsOneWidget);

    // Verify Stat Cards
    expect(find.text('Phim đã xem'), findsWidgets);
    expect(find.text('Watchlist'), findsOneWidget);
    expect(find.text('Đánh giá'), findsOneWidget);

    // Verify Glass Menu items
    expect(find.text('Chỉnh sửa profile'), findsOneWidget);
    expect(find.text('Video đã xem'), findsWidgets);
    expect(find.text('Chế độ Giao diện'), findsOneWidget);
    expect(find.text('Cài đặt thông báo'), findsOneWidget);
    expect(find.text('Chính sách & Bảo mật'), findsOneWidget);

    // Verify Logout button
    expect(find.text('Đăng Xuất'), findsOneWidget);
  });
}
