import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/core/theme/app_colors.dart';
import 'package:movie_app/core/theme/app_theme.dart';
import 'package:movie_app/core/theme/app_typography.dart';
import 'package:movie_app/core/theme/theme_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AppColors Tests', () {
    test('AppColors palette values are properly configured', () {
      expect(AppColors.darkBackground, equals(const Color(0xFF0B0E14)));
      expect(AppColors.darkSurface, equals(const Color(0xFF151C28)));
      expect(AppColors.primaryRed, equals(const Color(0xFFFF2A5F)));
      expect(AppColors.accentGold, equals(const Color(0xFFFFC107)));
      expect(AppColors.lightBackground, equals(const Color(0xFFFFFFFF)));
    });
  });

  group('AppTypography Tests', () {
    test('Dark and light text themes define required typography scales', () {
      expect(AppTypography.darkTextTheme.displayLarge, isNotNull);
      expect(AppTypography.darkTextTheme.headlineLarge, isNotNull);
      expect(AppTypography.darkTextTheme.bodyLarge, isNotNull);
      expect(AppTypography.darkTextTheme.labelLarge, isNotNull);

      expect(AppTypography.lightTextTheme.displayLarge, isNotNull);
      expect(AppTypography.lightTextTheme.headlineLarge, isNotNull);
      expect(AppTypography.lightTextTheme.bodyLarge, isNotNull);
      expect(AppTypography.lightTextTheme.labelLarge, isNotNull);
    });
  });

  group('AppTheme Tests', () {
    test('darkTheme has expected dark brightness and palette configuration',
        () {
      final theme = AppTheme.darkTheme;
      expect(theme.brightness, equals(Brightness.dark));
      expect(theme.scaffoldBackgroundColor, equals(AppColors.darkBackground));
      expect(theme.colorScheme.primary, equals(AppColors.primaryRed));
      expect(theme.colorScheme.secondary, equals(AppColors.accentGold));
      expect(theme.useMaterial3, isTrue);
    });

    test('lightTheme has expected light brightness and palette configuration',
        () {
      final theme = AppTheme.lightTheme;
      expect(theme.brightness, equals(Brightness.light));
      expect(theme.scaffoldBackgroundColor, equals(AppColors.lightBackground));
      expect(theme.colorScheme.primary, equals(AppColors.primaryRed));
      expect(theme.colorScheme.secondary, equals(AppColors.accentGold));
      expect(theme.useMaterial3, isTrue);
    });
  });

  group('ThemeCubit Tests', () {
    blocTest<ThemeCubit, ThemeMode>(
      'emits [ThemeMode.light] when toggleTheme is called on dark mode',
      build: () => ThemeCubit(),
      act: (cubit) => cubit.toggleTheme(),
      expect: () => [ThemeMode.light],
    );

    blocTest<ThemeCubit, ThemeMode>(
      'emits [ThemeMode.light, ThemeMode.dark] when toggleTheme is called twice',
      build: () => ThemeCubit(),
      act: (cubit) async {
        await cubit.toggleTheme();
        await cubit.toggleTheme();
      },
      expect: () => [ThemeMode.light, ThemeMode.dark],
    );

    blocTest<ThemeCubit, ThemeMode>(
      'emits [ThemeMode.system] when setThemeMode(ThemeMode.system) is called',
      build: () => ThemeCubit(),
      act: (cubit) => cubit.setThemeMode(ThemeMode.system),
      expect: () => [ThemeMode.system],
    );
  });
}
