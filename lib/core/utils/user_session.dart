import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../router/route_names.dart';
import '../theme/app_colors.dart';

class UserSession {
  UserSession._();
  static final UserSession instance = UserSession._();

  bool _isGuestMode = false;

  bool get isGuestMode => _isGuestMode;

  void setGuestMode(bool guest) {
    _isGuestMode = guest;
  }

  /// Checks if user is authenticated via Supabase or has a logged in session.
  bool get isAuthenticated {
    if (_isGuestMode) return false;
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) return true;
    } catch (_) {}
    return !_isGuestMode;
  }

  /// Performs [onAuthenticated] if authenticated, otherwise shows auth requirement dialog.
  void requireAuth(
    BuildContext context, {
    required VoidCallback onAuthenticated,
    required String actionName,
  }) {
    if (isAuthenticated) {
      onAuthenticated();
    } else {
      showAuthRequiredDialog(context, actionName: actionName);
    }
  }

  /// Displays an attractive dialog inviting non-registered / guest users to log in or register.
  void showAuthRequiredDialog(
    BuildContext context, {
    required String actionName,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.darkSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.primaryRed, width: 1.5),
          ),
          title: const Row(
            children: [
              Icon(Icons.lock_outline_rounded, color: AppColors.primaryRed),
              SizedBox(width: 10),
              Text(
                'Yêu Cầu Đăng Nhập',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Text(
            'Bạn cần đăng ký tài khoản hoặc đăng nhập để $actionName!',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Để sau',
                style: TextStyle(color: Colors.white54),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                try {
                  context.push(RoutePath.login);
                } catch (_) {
                  Navigator.pushNamed(context, RoutePath.login);
                }
              },
              child: const Text('Đăng Nhập / Đăng Ký'),
            ),
          ],
        );
      },
    );
  }
}
