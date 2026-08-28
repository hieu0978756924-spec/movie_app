import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Widget hiển thị thông báo toast khi thêm/xóa phim yêu thích.
/// Sử dụng ScaffoldMessenger để hiển thị SnackBar.
class FavoriteToast {
  static void show(
    BuildContext context, {
    required String movieTitle,
    required bool isAdded,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.darkSurface,
        content: Row(
          children: [
            Icon(
              isAdded ? Icons.favorite : Icons.favorite_border,
              color: isAdded ? AppColors.primaryRed : Colors.white70,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isAdded
                    ? 'Đã thêm "$movieTitle" vào danh sách yêu thích'
                    : 'Đã xóa "$movieTitle" khỏi danh sách yêu thích',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
