import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/di/injection.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_cubit.dart';
import '../../../core/utils/user_session.dart';

import '../../auth/views/login_view.dart';
import '../../watchlist/data/datasources/watchlist_local_datasource.dart';
import '../data/user_profile_manager.dart';
import '../data/watch_history_manager.dart';
import 'personal_info_view.dart';
import 'watched_videos_view.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  void _navigateToPersonalInfo(BuildContext context) {
    try {
      context.push(RoutePath.personalInfo);
    } catch (_) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const PersonalInfoView(),
        ),
      );
    }
  }

  void _navigateToWatchedVideos(BuildContext context) {
    try {
      context.push(RoutePath.watchedVideos);
    } catch (_) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const WatchedVideosView(),
        ),
      );
    }
  }

  void _navigateToWatchlist(BuildContext context) {
    try {
      context.push(RoutePath.watchlist);
    } catch (_) {}
  }

  ThemeCubit _getOrCreateThemeCubit(BuildContext context) {
    try {
      return BlocProvider.of<ThemeCubit>(context);
    } catch (_) {
      try {
        return getIt<ThemeCubit>();
      } catch (_) {
        return ThemeCubit();
      }
    }
  }

  void _showEditNameDialog(BuildContext context, String currentName) {
    final controller = TextEditingController(text: currentName);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
          title: Text(
            'Đổi Tên Hiển Thị',
            style: TextStyle(
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: controller,
            style: TextStyle(
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
            decoration: InputDecoration(
              labelText: 'Họ và Tên',
              hintText: 'Nhập tên mới...',
              labelStyle: TextStyle(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.primaryRed, width: 1.5),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Hủy',
                style: TextStyle(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final newName = controller.text.trim();
                if (newName.isNotEmpty) {
                  UserProfileManager.instance.updateProfile(name: newName);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã cập nhật tên hiển thị thành công!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
              ),
              child: const Text('Lưu', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showAvatarPickerDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final urlController = TextEditingController();

    final presets = [
      'assets/images/avatar.jpg',
      'assets/images/logo_movie.png',
      'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200',
      'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=200',
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chọn Ảnh Đại Diện',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 80,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: presets.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (_, index) {
                      final item = presets[index];
                      final isAsset = item.startsWith('assets/');
                      return GestureDetector(
                        onTap: () {
                          UserProfileManager.instance.updateProfile(avatarPath: item);
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đã thay đổi ảnh đại diện!'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        },
                        child: CircleAvatar(
                          radius: 36,
                          backgroundImage: isAsset
                              ? AssetImage(item) as ImageProvider
                              : NetworkImage(item),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Hoặc nhập URL ảnh:',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: urlController,
                        style: TextStyle(
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'https://example.com/avatar.jpg',
                          hintStyle: TextStyle(
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        final url = urlController.text.trim();
                        if (url.isNotEmpty) {
                          UserProfileManager.instance.updateProfile(avatarPath: url);
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đã cập nhật ảnh đại diện mới!'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryRed,
                      ),
                      child: const Text('Áp dụng', style: TextStyle(color: Colors.white)),
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

  void _showLogoutConfirmDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
          title: Text(
            'Đăng Xuất',
            style: TextStyle(
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng Góc Phim?',
            style: TextStyle(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Hủy',
                style: TextStyle(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                try {
                  await Supabase.instance.client.auth.signOut();
                } catch (_) {}
                UserSession.instance.setGuestMode(true);
                if (context.mounted) {
                  try {
                    context.go(RoutePath.login);
                  } catch (_) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginView(),
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
              ),
              child: const Text('Đăng Xuất', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<int> _fetchWatchlistCount() async {
    try {
      final list = await getIt<WatchlistLocalDataSource>().getWatchlist();
      return list.length;
    } catch (_) {
      return 0;
    }
  }

  ImageProvider _getAvatarImage(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return NetworkImage(path);
    }
    return AssetImage(path);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = _getOrCreateThemeCubit(context);
    return BlocProvider<ThemeCubit>.value(
      value: cubit,
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          final isDark = themeMode == ThemeMode.dark;

          return Scaffold(
            backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
            appBar: AppBar(
              backgroundColor: (isDark ? AppColors.darkBackground : AppColors.lightBackground)
                  .withAlpha(200),
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: Icon(
                  Icons.menu,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
                onPressed: () {},
              ),
              title: const Text(
                'Tài Khoản',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryRed,
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.notifications_outlined,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  //-----------------------------------------
                  // PROFILE HEADER (AVATAR, NAME, VIP BADGE, EMAIL)
                  //-----------------------------------------
                  ValueListenableBuilder<UserProfile>(
                    valueListenable: UserProfileManager.instance.profile,
                    builder: (context, profile, child) {
                      return Column(
                        children: [
                          Center(
                            child: Stack(
                              children: [
                                GestureDetector(
                                  onTap: () => _showAvatarPickerDialog(context),
                                  child: Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.primaryRed,
                                        width: 2.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primaryRed.withAlpha(80),
                                          blurRadius: 16,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: CircleAvatar(
                                      radius: 52,
                                      backgroundImage: _getAvatarImage(profile.avatarPath),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () => _showAvatarPickerDialog(context),
                                    child: Container(
                                      padding: const EdgeInsets.all(7),
                                      decoration: const BoxDecoration(
                                        color: AppColors.primaryRed,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black38,
                                            blurRadius: 6,
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Name + VIP Badge Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () => _showEditNameDialog(context, profile.name),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      profile.name,
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? AppColors.darkTextPrimary
                                            : AppColors.lightTextPrimary,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Icon(
                                      Icons.edit,
                                      size: 18,
                                      color: isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.lightTextSecondary,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFB800).withAlpha(40),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(0xFFFFB800).withAlpha(100),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.star_rounded,
                                      color: Color(0xFFFFB800),
                                      size: 13,
                                    ),
                                    SizedBox(width: 3),
                                    Text(
                                      'VIP',
                                      style: TextStyle(
                                        color: Color(0xFFFFB800),
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),

                          // Email
                          Text(
                            profile.email,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 28),

                  //-----------------------------------------
                  // STATS CARDS SECTION (3 GLASS CARDS)
                  //-----------------------------------------
                  ValueListenableBuilder<List<WatchedVideoItem>>(
                    valueListenable: WatchHistoryManager.instance.history,
                    builder: (context, watchedList, child) {
                      return Row(
                        children: [
                          // Phim đã xem Card
                          Expanded(
                            child: _buildStatCard(
                              context,
                              title: 'Phim đã xem',
                              count: watchedList.length.toString(),
                              accentColor: AppColors.primaryRed,
                              isDark: isDark,
                              onTap: () => _navigateToWatchedVideos(context),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Watchlist Card
                          Expanded(
                            child: FutureBuilder<int>(
                              future: _fetchWatchlistCount(),
                              builder: (context, snapshot) {
                                final count = snapshot.data?.toString() ?? '0';
                                return _buildStatCard(
                                  context,
                                  title: 'Watchlist',
                                  count: count,
                                  accentColor: AppColors.accentGold,
                                  isDark: isDark,
                                  onTap: () => _navigateToWatchlist(context),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Đánh giá Card
                          Expanded(
                            child: ValueListenableBuilder<int>(
                              valueListenable: UserProfileManager.instance.reviewCountNotifier,
                              builder: (context, reviewCount, child) {
                                return _buildStatCard(
                                  context,
                                  title: 'Đánh giá',
                                  count: reviewCount.toString(),
                                  accentColor: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                                  isDark: isDark,
                                  onTap: () {},
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 28),

                  //-----------------------------------------
                  // MENU LIST SECTION (GLASS PANEL CONTAINER)
                  //-----------------------------------------
                  Material(
                    color: isDark ? AppColors.darkCard : AppColors.lightCard,
                    borderRadius: BorderRadius.circular(16),
                    clipBehavior: Clip.antiAlias,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? Colors.white.withAlpha(15) : Colors.black.withAlpha(10),
                        ),
                        boxShadow: isDark
                            ? []
                            : [
                                BoxShadow(
                                  color: Colors.black.withAlpha(8),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                      ),
                      child: Column(
                        children: [
                          _buildMenuItem(
                            context,
                            icon: Icons.person_outline,
                            title: 'Chỉnh sửa profile',
                            isDark: isDark,
                            onTap: () => _navigateToPersonalInfo(context),
                          ),
                          _buildDivider(isDark),
                          _buildMenuItem(
                            context,
                            icon: Icons.history,
                            title: 'Video đã xem',
                            isDark: isDark,
                            onTap: () => _navigateToWatchedVideos(context),
                          ),
                          _buildDivider(isDark),
                          _buildMenuItemWithSwitch(
                            context,
                            icon: isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                            title: 'Chế độ Giao diện (Tối / Sáng)',
                            value: isDark,
                            isDark: isDark,
                            onChanged: (val) {
                              getIt<ThemeCubit>().setThemeMode(
                                val ? ThemeMode.dark : ThemeMode.light,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  //-----------------------------------------
                  // LOGOUT BUTTON (PINK NEON STITCH BUTTON)
                  //-----------------------------------------
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () => _showLogoutConfirmDialog(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryRed,
                        foregroundColor: Colors.white,
                        elevation: 6,
                        shadowColor: AppColors.primaryRed.withAlpha(120),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.logout, color: Colors.white),
                      label: const Text(
                        'Đăng Xuất',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String count,
    required Color accentColor,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white.withAlpha(15) : Colors.black.withAlpha(10),
          ),
        ),
        child: Column(
          children: [
            Text(
              count,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(
        icon,
        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
      ),
    );
  }

  Widget _buildMenuItemWithSwitch(
    BuildContext context, {
    required IconData icon,
    required String title,
    required bool value,
    required bool isDark,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        ),
      ),
      trailing: Switch(
        value: value,
        activeThumbColor: AppColors.primaryRed,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 1,
      color: isDark ? Colors.white.withAlpha(15) : Colors.black.withAlpha(10),
    );
  }
}