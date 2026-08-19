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

  /// Checks if user is authenticated via Supabase session.
  /// If in guest mode, this is always false.
  bool get isAuthenticated {
    if (_isGuestMode) return false;
    try {
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null && session.user.id.isNotEmpty) {
        return true;
      }
    } catch (_) {}
    return false;
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

  /// Displays an attractive cinematic dialog inviting guest users to log in or register.
  void showAuthRequiredDialog(
    BuildContext context, {
    required String actionName,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightCard,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.primaryRed.withAlpha(120),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryRed.withAlpha(50),
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: Colors.black.withAlpha(isDark ? 160 : 40),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Glowing Icon Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryRed.withAlpha(30),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primaryRed.withAlpha(80),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.lock_rounded,
                    color: AppColors.primaryRed,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 18),

                // Title
                Text(
                  'Yêu Cầu Đăng Nhập',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),

                // Description
                Text(
                  'Bạn đang ở Chế độ Trải nghiệm (Khách). Vui lòng đăng nhập hoặc tạo tài khoản để $actionName!',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          side: BorderSide(
                            color: isDark ? Colors.white24 : Colors.black26,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.pop(ctx),
                        child: Text(
                          'Để sau',
                          style: TextStyle(
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryRed,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          elevation: 4,
                          shadowColor: AppColors.primaryRed.withAlpha(120),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          UserSession.instance.setGuestMode(false);
                          try {
                            context.push(RoutePath.login);
                          } catch (_) {
                            context.go(RoutePath.login);
                          }
                        },
                        icon: const Icon(Icons.login_rounded, size: 18),
                        label: const Text(
                          'Đăng Nhập Ngay',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

