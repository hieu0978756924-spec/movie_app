import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/core/di/injection.dart';
import 'package:movie_app/core/router/app_router.dart';
import 'package:movie_app/core/router/route_names.dart';
import 'package:movie_app/features/auth/presentation/bloc/auth_bloc.dart';

class MockAuthBloc extends Mock implements AuthBloc {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockAuthBloc mockAuthBloc;

  group('RouteNames & RoutePaths Tests', () {
    test('RouteName constants are non-empty and unique', () {
      expect(RouteName.splash, equals('splash'));
      expect(RouteName.login, equals('login'));
      expect(RouteName.register, equals('register'));
      expect(RouteName.home, equals('home'));
      expect(RouteName.category, equals('category'));
      expect(RouteName.movieDetail, equals('movieDetail'));
      expect(RouteName.search, equals('search'));
      expect(RouteName.watchlist, equals('watchlist'));
      expect(RouteName.profile, equals('profile'));
    });

    test('RoutePath constants and helper methods formatted correctly', () {
      expect(RoutePath.splash, equals('/splash'));
      expect(RoutePath.login, equals('/login'));
      expect(RoutePath.register, equals('/register'));
      expect(RoutePath.home, equals('/'));
      expect(RoutePath.category, equals('/category/:type'));
      expect(RoutePath.movieDetail, equals('/movie/:id'));
      expect(RoutePath.search, equals('/search'));
      expect(RoutePath.watchlist, equals('/watchlist'));
      expect(RoutePath.profile, equals('/profile'));

      expect(RoutePath.movieDetailPath('456'), equals('/movie/456'));
      expect(RoutePath.categoryPath('popular'), equals('/category/popular'));
    });
  });

  group('AppRouter Configuration & Redirect Tests', () {
    setUp(() async {
      await GetIt.instance.reset();
      configureDependencies();
      mockAuthBloc = MockAuthBloc();

      when(() => mockAuthBloc.state).thenReturn(AuthInitialState());
      when(() => mockAuthBloc.stream).thenAnswer((_) => const Stream.empty());
      when(() => mockAuthBloc.close()).thenAnswer((_) async {});

      if (getIt.isRegistered<AuthBloc>()) {
        getIt.unregister<AuthBloc>();
      }
      getIt.registerFactory<AuthBloc>(() => mockAuthBloc);
    });

    tearDown(() {
      AppRouter.setAuthCheckOverride(null);
    });

    test('AppRouter contains all expected routes', () {
      final routes = <String>[];
      for (final r in AppRouter.router.configuration.routes) {
        if (r is GoRoute) {
          routes.add(r.path);
        } else if (r is StatefulShellRoute) {
          for (final branch in r.branches) {
            for (final subRoute in branch.routes) {
              if (subRoute is GoRoute) {
                routes.add(subRoute.path);
              }
            }
          }
        }
      }

      expect(routes, contains(RoutePath.splash));
      expect(routes, contains(RoutePath.login));
      expect(routes, contains(RoutePath.register));
      expect(routes, contains(RoutePath.home));
      expect(routes, contains(RoutePath.category));
      expect(routes, contains(RoutePath.movieDetail));
      expect(routes, contains(RoutePath.search));
      expect(routes, contains(RoutePath.watchlist));
      expect(routes, contains(RoutePath.profile));
    });

    testWidgets(
        'Unauthenticated user navigating to protected route is redirected to /login',
        (tester) async {
      AppRouter.setAuthCheckOverride(() => false);

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: AppRouter.router,
        ),
      );

      AppRouter.router.go(RoutePath.home);
      await tester.pumpAndSettle();

      expect(
        AppRouter.router.routerDelegate.currentConfiguration.uri.path,
        equals(RoutePath.login),
      );
    });

    testWidgets('Authenticated user navigating to /login is redirected to /',
        (tester) async {
      AppRouter.setAuthCheckOverride(() => true);

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: AppRouter.router,
        ),
      );

      AppRouter.router.go(RoutePath.login);
      await tester.pumpAndSettle();

      expect(
        AppRouter.router.routerDelegate.currentConfiguration.uri.path,
        equals(RoutePath.home),
      );
    });

    testWidgets('Authenticated user can navigate to deep-link /movie/123',
        (tester) async {
      AppRouter.setAuthCheckOverride(() => true);

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: AppRouter.router,
        ),
      );

      AppRouter.router.go(RoutePath.movieDetailPath('123'));
      await tester.pumpAndSettle();

      expect(
        AppRouter.router.routerDelegate.currentConfiguration.uri.path,
        equals('/movie/123'),
      );
    });
  });
}
