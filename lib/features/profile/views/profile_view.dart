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
                          Container(
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
                              backgroundImage: AssetImage(profile.avatarPath),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () => _navigateToPersonalInfo(context),
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
                                  Icons.edit,
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
                      child: _buildStatCard(
                        context,
                        title: 'Watchlist',
                        count: '12',
                        accentColor: AppColors.accentGold,
                        isDark: isDark,
                        onTap: () => _navigateToWatchlist(context),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Đánh giá Card
                    Expanded(
                      child: _buildStatCard(
                        context,
                        title: 'Đánh giá',
                        count: '18',
                        accentColor: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                        isDark: isDark,
                        onTap: () {},
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
                    title: 'Chế độ Giao diện',
                    value: isDark,
                    isDark: isDark,
                    onChanged: (val) {
                      getIt<ThemeCubit>().setThemeMode(
                        val ? ThemeMode.dark : ThemeMode.light,
                      );
                    },
                  ),
                  _buildDivider(isDark),
                  _buildMenuItem(
                    context,
                    icon: Icons.notifications_none,
                    title: 'Cài đặt thông báo',
                    isDark: isDark,
                    onTap: () {},
                  ),
                  _buildDivider(isDark),
                  _buildMenuItem(
                    context,
                    icon: Icons.security_outlined,
                    title: 'Chính sách & Bảo mật',
                    isDark: isDark,
                    onTap: () {},
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
                onPressed: () async {
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