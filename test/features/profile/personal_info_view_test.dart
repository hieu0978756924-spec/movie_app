import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:movie_app/features/profile/data/user_profile_manager.dart';
import 'package:movie_app/features/profile/views/personal_info_view.dart';
import 'package:movie_app/features/profile/views/profile_view.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    UserProfileManager.instance.profile.value = const UserProfile(
      name: 'Nguyễn Ngọc Như Hiếu',
      dob: '15/08/2000',
      gender: 'Nam',
      email: 'nhuhieu@gmail.com',
      avatarPath: 'assets/images/avatar.jpg',
    );
  });

  testWidgets('PersonalInfoView renders name, date of birth, gender, and email fields', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PersonalInfoView(),
      ),
    );

    // Verify Title
    expect(find.text('Thông tin cá nhân'), findsOneWidget);

    // Verify Field labels
    expect(find.text('Họ và tên'), findsOneWidget);
    expect(find.text('Ngày tháng năm sinh'), findsOneWidget);
    expect(find.text('Giới tính'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);

    // Verify default values in text fields
    expect(find.text('Nguyễn Ngọc Như Hiếu'), findsOneWidget);
    expect(find.text('15/08/2000'), findsOneWidget);
    expect(find.text('Nam'), findsOneWidget);
    expect(find.text('nhuhieu@gmail.com'), findsOneWidget);

    // Verify Save button
    expect(find.text('Lưu thay đổi'), findsOneWidget);
  });

  testWidgets('Updating PersonalInfo updates UserProfileManager state', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PersonalInfoView(),
      ),
    );

    // Enter new name and email
    final nameFinder = find.widgetWithText(TextFormField, 'Nguyễn Ngọc Như Hiếu');
    await tester.enterText(nameFinder, 'Trần Văn A');

    final emailFinder = find.widgetWithText(TextFormField, 'nhuhieu@gmail.com');
    await tester.enterText(emailFinder, 'tranvana@gmail.com');

    // Scroll to save button and tap
    final saveButton = find.text('Lưu thay đổi');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    // Verify UserProfileManager updated
    expect(UserProfileManager.instance.profile.value.name, 'Trần Văn A');
    expect(UserProfileManager.instance.profile.value.email, 'tranvana@gmail.com');
  });

  testWidgets('ProfileView reflects updated name and email dynamically', (WidgetTester tester) async {
    UserProfileManager.instance.updateProfile(
      name: 'Lê Thị B',
      email: 'lethib@gmail.com',
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: ProfileView(),
      ),
    );

    expect(find.text('Lê Thị B'), findsOneWidget);
    expect(find.text('lethib@gmail.com'), findsOneWidget);
  });
}
