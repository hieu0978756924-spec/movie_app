import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'route_names.dart';
import '../../features/auth/views/login_view.dart';
import '../../features/auth/views/register_view.dart';
import '../../features/auth/views/forgot_password_view.dart';
import '../../features/favorites/views/favorites_view.dart';
import '../../features/watchlist/presentation/views/watchlist_view.dart';
import '../../features/home/models/movie.dart';
import '../../features/home/views/category_view.dart';
import '../../features/home/views/home_view.dart';
import '../../features/home/views/main_layout_view.dart';
import '../../features/home/views/movie_detail_view.dart';
import '../../features/profile/views/personal_info_view.dart';
import '../../features/profile/views/profile_view.dart';
import '../../features/profile/views/watched_videos_view.dart';
import '../../features/profile/views/user_reviews_view.dart';
import '../../features/search/views/search_view.dart';
import '../../features/splash/views/splash_view.dart';
import '../../features/actor/presentation/pages/actor_detail_page.dart';
import '../../features/movie_detail/presentation/pages/movie_player_page.dart';
import '../../features/home/controllers/home_controller.dart';
import '../utils/user_session.dart';

class AppRouter {
  static bool Function()? _authCheckOverride;

  /// For testing purposes to override Supabase auth check
  static void setAuthCheckOverride(bool Function()? override) {
    _authCheckOverride = override;
  }

  static bool get isAuthenticated {
    if (_authCheckOverride != null) {
      return _authCheckOverride!();
    }
    if (UserSession.instance.isGuestMode) {
      return true;
    }
    try {
      return Supabase.instance.client.auth.currentSession != null;
    } catch (_) {
      return false;
    }
  }

  static final router = GoRouter(
    initialLocation: RoutePath.splash,
    redirect: (context, state) {
      final isSplash = state.matchedLocation == RoutePath.splash;
      final isLoggingIn = state.matchedLocation == RoutePath.login;
      final isRegistering = state.matchedLocation == RoutePath.register;
      if (isSplash || isRegistering) {
        return null;
      }

      if (!isAuthenticated && !isLoggingIn) {
        return RoutePath.login;
      }

      if (isAuthenticated && !UserSession.instance.isGuestMode && isLoggingIn) {
        return RoutePath.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: RoutePath.splash,
        name: RouteName.splash,
        builder: (context, state) => const SplashView(),
      ),
      GoRoute(
        path: RoutePath.login,
        name: RouteName.login,
        builder: (context, state) => const LoginView(),
      ),
      GoRoute(
        path: RoutePath.register,
        name: RouteName.register,
        builder: (context, state) => const RegisterView(),
      ),
      GoRoute(
        path: RoutePath.forgotPassword,
        name: RouteName.forgotPassword,
        builder: (context, state) => const ForgotPasswordView(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainLayoutView(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePath.home,
                name: RouteName.home,
                builder: (context, state) => const HomeView(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePath.watchlist,
                name: RouteName.watchlist,
                builder: (context, state) => const WatchlistView(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePath.favorites,
                name: RouteName.favorites,
                builder: (context, state) => const FavoritesView(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePath.profile,
                name: RouteName.profile,
                builder: (context, state) => const ProfileView(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: RoutePath.search,
        name: RouteName.search,
        builder: (context, state) => const SearchView(),
      ),
      GoRoute(
        path: RoutePath.personalInfo,
        name: RouteName.personalInfo,
        builder: (context, state) => const PersonalInfoView(),
      ),
      GoRoute(
        path: RoutePath.watchedVideos,
        name: RouteName.watchedVideos,
        builder: (context, state) => const WatchedVideosView(),
      ),
      GoRoute(
        path: RoutePath.userReviews,
        name: RouteName.userReviews,
        builder: (context, state) => const UserReviewsView(),
      ),
      GoRoute(
        path: RoutePath.category,
        name: RouteName.category,
        builder: (context, state) {
          final categoryType = state.pathParameters['type'] ?? 'popular';
          return CategoryView(categoryType: categoryType);
        },
      ),
      GoRoute(
        path: RoutePath.movieDetail,
        name: RouteName.movieDetail,
        builder: (context, state) {
          final movieExtra = state.extra;
          if (movieExtra is Movie) {
            return MovieDetailView(movie: movieExtra);
          }
          final movieId = state.pathParameters['id'] ?? '0';
          final parsedId = int.tryParse(movieId) ?? 0;
          final fallbackMovie = Movie(
            id: parsedId,
            tenPhim: 'Phim #$movieId',
            hinhAnh: 'assets/images/dune2.jpg',
            theLoai: 'Action',
            diemDanhGia: 8.0,
            thoiLuong: '120 min',
            moTa: 'Chi tiết phim ID $movieId',
            namPhatHanh: 2026,
            daoDien: 'Góc Phim',
          );
          return MovieDetailView(movie: fallbackMovie);
        },
      ),
      GoRoute(
        path: RoutePath.actorDetail,
        name: RouteName.actorDetail,
        builder: (context, state) {
          final actorIdStr = state.pathParameters['id'] ?? '101';
          final actorId = int.tryParse(actorIdStr) ?? 101;
          return ActorDetailPage(actorId: actorId);
        },
      ),
      GoRoute(
        path: RoutePath.moviePlayer,
        name: RouteName.moviePlayer,
        builder: (context, state) {
          final movieExtra = state.extra;
          final keyQuery = state.uri.queryParameters['key'];

          if (movieExtra is Movie) {
            return MoviePlayerPage(
              movie: movieExtra,
              youtubeKey: keyQuery ??
                  (movieExtra.trailerUrl.isNotEmpty
                      ? movieExtra.trailerUrl
                      : null),
            );
          }
          if (movieExtra is Map<String, dynamic>) {
            final movie = movieExtra['movie'] as Movie;
            final youtubeKey = movieExtra['key'] as String?;
            return MoviePlayerPage(
              movie: movie,
              youtubeKey: youtubeKey ?? keyQuery,
            );
          }
          final movieIdStr = state.pathParameters['id'] ?? '1';
          final movieId = int.tryParse(movieIdStr) ?? 1;
          final movie = HomeController.instance.danhSachPhim.firstWhere(
            (m) => m.id == movieId,
            orElse: () => HomeController.instance.danhSachPhim.first,
          );
          return MoviePlayerPage(
            movie: movie,
            youtubeKey: keyQuery,
          );
        },
      ),
    ],
  );
}
