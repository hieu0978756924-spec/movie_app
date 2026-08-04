import 'package:shared_preferences/shared_preferences.dart';

class PreferenceService {
  static const String loginKey = "isLogin";

  //==========================
  // Lưu trạng thái đăng nhập
  //==========================

  static Future<void> saveLogin(bool value) async {
    final pref = await SharedPreferences.getInstance();

    await pref.setBool(loginKey, value);
  }

  //==========================
  // Kiểm tra đã đăng nhập?
  //==========================

  static Future<bool> isLogin() async {
    final pref = await SharedPreferences.getInstance();

    return pref.getBool(loginKey) ?? false;
  }

  //==========================
  // Đăng xuất
  //==========================

  static Future<void> logout() async {
    final pref = await SharedPreferences.getInstance();

    await pref.remove(loginKey);
  }
}