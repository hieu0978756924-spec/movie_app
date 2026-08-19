import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../review/data/datasources/user_review_manager.dart';


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
        name: 'Thành viên Góc Phim',
        dob: '',
        gender: '',
        email: '',
        avatarPath: 'assets/images/avatar.jpg',
      ),
    );
    loadProfile();
  }

  static final UserProfileManager instance = UserProfileManager._internal();

  late final ValueNotifier<UserProfile> profile;
  final ValueNotifier<int> reviewCountNotifier = ValueNotifier<int>(0);

  void resetForUser({
    required String email,
    String? name,
    String? dob,
    String? gender,
    String? avatarPath,
  }) {
    final defaultName = (name != null && name.isNotEmpty)
        ? name
        : (email.contains('@') ? email.split('@').first : 'Thành viên Góc Phim');
    final freshProfile = UserProfile(
      name: defaultName,
      dob: dob ?? '',
      gender: gender ?? '',
      email: email,
      avatarPath: avatarPath ?? 'assets/images/avatar.jpg',
    );
    profile.value = freshProfile;
    reviewCountNotifier.value = 0;
    _saveProfile(freshProfile);
  }

  Future<void> loadProfile([String? explicitEmail]) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String currentEmail = explicitEmail ?? profile.value.email;
      try {
        final supabaseUser = Supabase.instance.client.auth.currentUser;
        if (supabaseUser?.email != null && supabaseUser!.email!.isNotEmpty) {
          currentEmail = supabaseUser.email!;
        }
      } catch (_) {}

      final emailKey = currentEmail.isNotEmpty ? '_${currentEmail.toLowerCase()}' : '';
      final savedEmail = prefs.getString('profile_email$emailKey') ?? prefs.getString('profile_email');
      var savedName = prefs.getString('profile_name$emailKey');
      final savedDob = prefs.getString('profile_dob$emailKey');
      final savedGender = prefs.getString('profile_gender$emailKey');
      final savedAvatar = prefs.getString('profile_avatar$emailKey');

      try {
        final supabaseUser = Supabase.instance.client.auth.currentUser;
        final metaName = supabaseUser?.userMetadata?['name'] ?? supabaseUser?.userMetadata?['full_name'];
        if (metaName != null && metaName.toString().isNotEmpty) {
          savedName = metaName.toString();
        }
      } catch (_) {}

      final finalEmail = currentEmail.isNotEmpty ? currentEmail : (savedEmail ?? profile.value.email);
      final defaultName = (savedName != null && savedName.isNotEmpty)
          ? savedName
          : (profile.value.name.isNotEmpty
              ? profile.value.name
              : (finalEmail.contains('@') ? finalEmail.split('@').first : 'Thành viên Góc Phim'));

      profile.value = UserProfile(
        name: defaultName,
        dob: (savedDob != null && savedDob.isNotEmpty) ? savedDob : profile.value.dob,
        gender: (savedGender != null && savedGender.isNotEmpty) ? savedGender : profile.value.gender,
        email: finalEmail,
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
        reviewCountNotifier.value = UserReviewManager.instance.userReviews.length;
      }
    } catch (_) {
      reviewCountNotifier.value = UserReviewManager.instance.userReviews.length;
    }
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
      final emailKey = userProfile.email.isNotEmpty ? '_${userProfile.email.toLowerCase()}' : '';
      await prefs.setString('profile_name$emailKey', userProfile.name);
      await prefs.setString('profile_dob$emailKey', userProfile.dob);
      await prefs.setString('profile_gender$emailKey', userProfile.gender);
      await prefs.setString('profile_email$emailKey', userProfile.email);
      await prefs.setString('profile_avatar$emailKey', userProfile.avatarPath);

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
