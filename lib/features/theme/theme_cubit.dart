import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tunely/core/config/app_theme.dart';
import 'package:tunely/features/theme/theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit()
    : super(ThemeState(mode: ThemeMode.dark, accent: AppTheme.defaultAccent)) {
    _load();
  }

  static const _modeKey = 'theme_mode';
  static const _accentKey = 'accent_color';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_modeKey);
    final modeName = prefs.getString(_modeKey) ?? 'dark';
    final accentValue =
        prefs.getInt(_accentKey) ?? AppTheme.defaultAccent.toARGB32();

    final mode = switch (modeName) {
      'light' => ThemeMode.light,
      'system' => ThemeMode.system,
      _ => ThemeMode.dark,
    };

    emit(ThemeState(mode: mode, accent: Color(accentValue)));
  }

  Future<void> toggleTheme() async {
    final newMode = switch (state.mode) {
      ThemeMode.dark => ThemeMode.light,
      ThemeMode.light => ThemeMode.system,
      ThemeMode.system => ThemeMode.dark,
    };
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_modeKey, newMode.name);
    emit(state.copyWith(mode: newMode));
  }

  Future<void> setAccent(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_accentKey, color.toARGB32());
    emit(state.copyWith(accent: color));
  }

  Future<void> resetAccent() async {
    await setAccent(AppTheme.defaultAccent);
  }
}
