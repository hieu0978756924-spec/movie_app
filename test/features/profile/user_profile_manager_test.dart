import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/features/profile/data/user_profile_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('UserProfileManager Tests', () {
    test('default profile properties are initialized correctly', () {
      final manager = UserProfileManager.instance;
      expect(manager.profile.value.name, isNotEmpty);
      expect(manager.profile.value.email, isNotEmpty);
      expect(manager.profile.value.avatarPath, isNotEmpty);
    });

    test('updateProfile updates profile name and avatarPath', () {
      final manager = UserProfileManager.instance;
      manager.updateProfile(
        name: 'Tên Mới Test',
        avatarPath: 'assets/images/avatar_test.jpg',
      );

      expect(manager.profile.value.name, 'Tên Mới Test');
      expect(manager.profile.value.avatarPath, 'assets/images/avatar_test.jpg');
    });

    test('reviewCountNotifier can be updated', () {
      final manager = UserProfileManager.instance;
      manager.reviewCountNotifier.value = 5;
      expect(manager.reviewCountNotifier.value, 5);
    });
  });
}
