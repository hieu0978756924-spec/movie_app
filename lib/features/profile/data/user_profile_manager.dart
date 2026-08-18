import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserProfile {
  final String name;
  final String dob;
  final String gender;
  final String email;
  final String avatarPath;

  const UserProfile({
    required this.name,
    required this.dob,
    required this.gender,
    required this.email,
    this.avatarPath = 'assets/images/avatar.jpg',
  });

  UserProfile copyWith({
    String? name,
    String? dob,
    String? gender,
    String? email,
    String? avatarPath,
  }) {
    return UserProfile(
      name: name ?? this.name,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      email: email ?? this.email,
      avatarPath: avatarPath ?? this.avatarPath,
    );
  }
}

class UserProfileManager {
  UserProfileManager._internal() {
    profile = ValueNotifier<UserProfile>(
      const UserProfile(
        name: 'Nguyễn Ngọc Như Hiếu',
        dob: '15/08/2000',
        gender: 'Nam',
        email: 'nhuhieu@gmail.com',
        avatarPath: 'assets/images/avatar.jpg',
      ),
    );
    loadProfile();
  }

  static final UserProfileManager instance = UserProfileManager._internal();

  late final ValueNotifier<UserProfile> profile;
  final ValueNotifier<int> reviewCountNotifier = ValueNotifier<int>(0);

  Future<void> loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString('profile_email');
      var savedName = prefs.getString('profile_name');
      final savedDob = prefs.getString('profile_dob');
      final savedGender = prefs.getString('profile_gender');
      final savedAvatar = prefs.getString('profile_avatar');

      String currentEmail = savedEmail ?? profile.value.email;
      try {
        final supabaseUser = Supabase.instance.client.auth.currentUser;
        if (supabaseUser?.email != null && supabaseUser!.email!.isNotEmpty) {
          currentEmail = supabaseUser.email!;
        }
        final metaName = supabaseUser?.userMetadata?['name'] ?? supabaseUser?.userMetadata?['full_name'];
        if (metaName != null && metaName.toString().isNotEmpty) {
          savedName = metaName.toString();
        }
      } catch (_) {}

      profile.value = UserProfile(
        name: (savedName != null && savedName.isNotEmpty) ? savedName : profile.value.name,
        dob: (savedDob != null && savedDob.isNotEmpty) ? savedDob : profile.value.dob,
        gender: (savedGender != null && savedGender.isNotEmpty) ? savedGender : profile.value.gender,
        email: currentEmail,
        avatarPath: (savedAvatar != null && savedAvatar.isNotEmpty) ? savedAvatar : profile.value.avatarPath,
      );

      fetchReviewCount();
    } catch (_) {}
  }

  Future<void> fetchReviewCount() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final response = await Supabase.instance.client
            .from('reviews')
            .select('id')
            .eq('user_id', user.id);
        reviewCountNotifier.value = response.length;
      } else {
        reviewCountNotifier.value = 0;
      }
    } catch (_) {}
  }

  void updateProfile({
    String? name,
    String? dob,
    String? gender,
    String? email,
    String? avatarPath,
  }) {
    String newEmail = (email != null && email.isNotEmpty) ? email : profile.value.email;
    String newName = (name != null && name.isNotEmpty) ? name : profile.value.name;

    final updated = UserProfile(
      name: newName,
      dob: (dob != null && dob.isNotEmpty) ? dob : profile.value.dob,
      gender: (gender != null && gender.isNotEmpty) ? gender : profile.value.gender,
      email: newEmail,
      avatarPath: (avatarPath != null && avatarPath.isNotEmpty) ? avatarPath : profile.value.avatarPath,
    );
    profile.value = updated;
    _saveProfile(updated);
  }

  Future<void> _saveProfile(UserProfile userProfile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_name', userProfile.name);
      await prefs.setString('profile_dob', userProfile.dob);
      await prefs.setString('profile_gender', userProfile.gender);
      await prefs.setString('profile_email', userProfile.email);
      await prefs.setString('profile_avatar', userProfile.avatarPath);

      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await Supabase.instance.client.auth.updateUser(
          UserAttributes(data: {'full_name': userProfile.name, 'name': userProfile.name}),
        );
        await Supabase.instance.client.from('profiles').upsert({
          'id': user.id,
          'full_name': userProfile.name,
          'avatar_url': userProfile.avatarPath,
          'updated_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (_) {}
  }
}

