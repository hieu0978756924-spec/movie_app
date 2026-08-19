import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:movie_app/core/utils/user_session.dart';
import 'package:movie_app/features/profile/data/user_profile_manager.dart';
import 'package:movie_app/features/profile/views/profile_view.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    UserSession.instance.setGuestMode(false);
    UserProfileManager.instance.profile.value = const UserProfile(
      name: 'Nguyễn Ngọc Như Hiếu',
      dob: '15/08/2000',
      gender: 'Nam',
      email: 'nhuhieu@gmail.com',
      avatarPath: 'assets/images/avatar.jpg',
    );
  });

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
    expect(find.textContaining('Chế độ Giao diện'), findsOneWidget);

    // Verify Logout button
    expect(find.text('Đăng Xuất'), findsOneWidget);
  });
}
