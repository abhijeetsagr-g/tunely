import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tunely/core/config/app_theme.dart';
import 'package:tunely/features/theme/theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit()
    : super(ThemeState(mode: ThemeMode.dark, accent: AppTheme.defaultAccent));

  static const _modeKey = 'theme_mode';
  static const _accentKey = 'accent_color';
  static const _seenOnboardingKey = 'seen_onboarding';
  static const _dynamicThemeKey = 'dynamic_theme_enabled';

  bool _dynamicThemeEnabled = true;
  bool get dynamicThemeEnabled => _dynamicThemeEnabled;

  bool _seenOnboarding = false;
  bool get seenOnboarding => _seenOnboarding;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final modeName = prefs.getString(_modeKey) ?? 'dark';
    final accentValue =
        prefs.getInt(_accentKey) ?? AppTheme.defaultAccent.toARGB32();
    final mode = switch (modeName) {
      'light' => ThemeMode.light,
      'system' => ThemeMode.system,
      _ => ThemeMode.dark,
    };

    final dynamicTheme = prefs.getBool(_dynamicThemeKey) ?? true;
    _dynamicThemeEnabled = dynamicTheme;

    _seenOnboarding = prefs.getBool(_seenOnboardingKey) ?? false;
    emit(ThemeState(mode: mode, accent: Color(accentValue)));
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_seenOnboardingKey, true);
    _seenOnboarding = true;
  }

  Future<void> toggleDynamicTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _dynamicThemeEnabled = !_dynamicThemeEnabled;
    await prefs.setBool(_dynamicThemeKey, _dynamicThemeEnabled);

    emit(state);
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
    debugPrint("THEME CHANGED");
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
