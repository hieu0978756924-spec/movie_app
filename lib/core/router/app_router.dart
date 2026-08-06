import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'route_names.dart';
import '../../features/auth/views/forgot_password_view.dart';
import '../../features/auth/views/login_view.dart';
import '../../features/auth/views/register_view.dart';
import '../../features/favorite/views/favorite_view.dart';
import '../../features/home/models/movie.dart';
import '../../features/home/views/home_view.dart';
import '../../features/home/views/movie_detail_view.dart';
import '../../features/profile/views/profile_view.dart';
import '../../features/search/views/search_view.dart';
import '../../features/splash/views/splash_view.dart';

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
    try {
      return Supabase.instance.client.auth.currentSession != null;
    } catch (_) {
      return false;
    }
  }

  static final GoRouter router = GoRouter(
    initialLocation: RoutePath.splash,
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
      GoRoute(
        path: RoutePath.home,
        name: RouteName.home,
        builder: (context, state) => const HomeView(),
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
          final fallbackMovie = Movie(
            tenPhim: 'Phim #$movieId',
            hinhAnh: 'assets/images/latmat7.jpg',
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
        path: RoutePath.search,
        name: RouteName.search,
        builder: (context, state) => const SearchView(),
      ),
      GoRoute(
        path: RoutePath.watchlist,
        name: RouteName.watchlist,
        builder: (context, state) => const FavoriteView(),
      ),
      GoRoute(
        path: RoutePath.profile,
        name: RouteName.profile,
        builder: (context, state) => const ProfileView(),
      ),
    ],
    redirect: (context, state) {
      final loggedIn = isAuthenticated;
      final matchedLocation = state.matchedLocation;

      final isAuthRoute = matchedLocation == RoutePath.login ||
          matchedLocation == RoutePath.register ||
          matchedLocation == RoutePath.forgotPassword;
      final isSplashRoute = matchedLocation == RoutePath.splash;

      if (!loggedIn) {
        if (!isAuthRoute && !isSplashRoute) {
          return RoutePath.login;
        }
      } else {
        if (isAuthRoute) {
          return RoutePath.home;
        }
      }

      return null;
    },
  );
}
