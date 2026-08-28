import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── Events ────────────────────────────────────────────────────────────────

abstract class ThemeEvent {}

class ToggleThemeEvent extends ThemeEvent {}

class SetThemeModeEvent extends ThemeEvent {
  final ThemeMode mode;
  SetThemeModeEvent(this.mode);
}

// ─── State = ThemeMode (dùng trực tiếp)

// ─── Cubit ─────────────────────────────────────────────────────────────────

@lazySingleton
class ThemeCubit extends Cubit<ThemeMode> {
  static const String themePreferenceKey = 'theme_mode';

  ThemeCubit() : super(ThemeMode.dark) {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString(themePreferenceKey);
      if (savedTheme == 'light') {
        emit(ThemeMode.light);
      } else if (savedTheme == 'system') {
        emit(ThemeMode.system);
      } else {
        emit(ThemeMode.dark);
      }
    } catch (_) {
      emit(ThemeMode.dark);
    }
  }

  Future<void> toggleTheme() async {
    final nextMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(nextMode);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    emit(mode);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(themePreferenceKey, mode.name);
    } catch (_) {}
  }
}
