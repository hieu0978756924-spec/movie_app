import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/image_url_helper.dart';
import '../../../core/utils/user_session.dart';
import '../../home/controllers/home_controller.dart';
import '../../home/models/movie.dart';

class FavoritesView extends StatefulWidget {
  const FavoritesView({super.key});

  @override
  State<FavoritesView> createState() => _FavoritesViewState();
}

class _FavoritesViewState extends State<FavoritesView> {
  bool _isSyncing = false;

  void _toggleFavorite(Movie movie) {
    UserSession.instance.requireAuth(
      context,
      actionName: 'quản lý danh sách phim yêu thích',
      onAuthenticated: () {
        setState(() {
          HomeController.instance.doiTrangThaiYeuThich(movie);
        });
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 2),
            backgroundColor: AppColors.darkSurface,
            content: Row(
              children: [
                Icon(
                  movie.yeuThich ? Icons.favorite : Icons.favorite_border,
                  color: movie.yeuThich ? AppColors.primaryRed : Colors.white70,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    movie.yeuThich
                        ? 'Đã thêm "${movie.tenPhim}" vào Phim yêu thích'
                        : 'Đã xóa "${movie.tenPhim}" khỏi Phim yêu thích',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _syncToCloud() async {
    UserSession.instance.requireAuth(
      context,
      actionName: 'đồng bộ danh sách yêu thích lên Cloud',
      onAuthenticated: () async {
        setState(() {
          _isSyncing = true;
        });
        await Future.delayed(const Duration(milliseconds: 1200));
        if (mounted) {
          setState(() {
            _isSyncing = false;
          });
        }
      },
    );
  }

  Widget _buildPoster(Movie movie) {
    final posterUrl = ImageUrlHelper.getPosterUrl(movie.hinhAnh);
    if (posterUrl != null && posterUrl.startsWith('http')) {
      return Image.network(
        posterUrl,
        width: 75,
        height: 110,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildFallbackPoster(movie),
      );
    }
    return _buildFallbackPoster(movie);
  }

  Widget _buildFallbackPoster(Movie movie) {
    final assetPath = movie.hinhAnh.startsWith('assets/')
        ? movie.hinhAnh
        : ImageUrlHelper.getLocalFallbackImage(movie.id);
    return Image.asset(
      assetPath,
      width: 75,
      height: 110,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        width: 75,
        height: 110,
        color: AppColors.darkSurfaceVariant,
        child: const Icon(Icons.movie_outlined, color: Colors.white38),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = AppLocalizations.of(context);
    final favoriteList = HomeController.instance.danhSachYeuThich;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor:
            isDark ? AppColors.darkSurface : AppColors.lightSurface,
        elevation: 0,
        title: Text(
          locale.translate('my_favorites'),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color:
                isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Đồng bộ Cloud',
            icon: _isSyncing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primaryRed,
                    ),
                  )
                : const Icon(
                    Icons.cloud_sync_rounded,
                    color: AppColors.primaryRed,
                  ),
            onPressed: _isSyncing ? null : _syncToCloud,
          ),
        ],
      ),
      body: UserSession.instance.isGuestMode
          ? _buildGuestLockState(context, isDark)
          : Column(
              children: [
                // Main Favorites List Body
                Expanded(
                  child: favoriteList.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.favorite_border_rounded,
                                size: 80,
                                color: isDark
                                    ? AppColors.darkTextMuted.withAlpha(120)
                                    : AppColors.lightTextMuted.withAlpha(120),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Chưa có phim yêu thích nào',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.lightTextPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 32),
                                child: Text(
                                  'Nhấn biểu tượng trái tim khi xem phim để lưu vào danh sách yêu thích và đồng bộ Đám mây!',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: favoriteList.length,
                          itemBuilder: (context, index) {
                            final movie = favoriteList[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 14),
                              color: isDark
                                  ? AppColors.darkCard
                                  : AppColors.lightCard,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                  color: isDark
                                      ? AppColors.glassBorder
                                      : Colors.black12,
                                ),
                              ),
                              elevation: isDark ? 0 : 2,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () async {
                                  await context.push(
                                    RoutePath.movieDetailPath(
                                        movie.id.toString()),
                                    extra: movie,
                                  );
                                  setState(() {});
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: _buildPoster(movie),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              movie.tenPhim,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: isDark
                                                    ? AppColors.darkTextPrimary
                                                    : AppColors
                                                        .lightTextPrimary,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8,
                                                      vertical: 3),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.primaryRed
                                                        .withAlpha(25),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                  ),
                                                  child: Text(
                                                    movie.theLoai
                                                        .split(',')
                                                        .first
                                                        .trim(),
                                                    style: const TextStyle(
                                                      color:
                                                          AppColors.primaryRed,
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.star_rounded,
                                                      color:
                                                          AppColors.accentGold,
                                                      size: 16,
                                                    ),
                                                    const SizedBox(width: 3),
                                                    Text(
                                                      '${movie.diemDanhGia.toStringAsFixed(1)} / 10',
                                                      style: TextStyle(
                                                        color: isDark
                                                            ? AppColors
                                                                .darkTextSecondary
                                                            : AppColors
                                                                .lightTextSecondary,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.favorite,
                                          color: AppColors.primaryRed,
                                        ),
                                        onPressed: () => _toggleFavorite(movie),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildGuestLockState(BuildContext context, bool isDark) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppColors.primaryRed.withAlpha(25),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primaryRed.withAlpha(90),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryRed.withAlpha(60),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.favorite_rounded,
                color: AppColors.primaryRed,
                size: 52,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Danh Sách Phim Yêu Thích',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Bạn đang ở Chế độ Trải nghiệm (Khách). Vui lòng đăng nhập hoặc tạo tài khoản để lưu trữ, đồng bộ và quản lý phim yêu thích trên Đám mây!',
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryRed,
                  foregroundColor: Colors.white,
                  elevation: 6,
                  shadowColor: AppColors.primaryRed.withAlpha(120),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  UserSession.instance.setGuestMode(false);
                  try {
                    context.push(RoutePath.login);
                  } catch (_) {
                    context.go(RoutePath.login);
                  }
                },
                icon: const Icon(Icons.login_rounded, size: 20),
                label: const Text(
                  'Đăng Nhập / Đăng Ký Ngay',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
