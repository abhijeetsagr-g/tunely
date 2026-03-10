import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tunely/core/config/app_colors.dart';
import 'package:tunely/logic/provider/theme/theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit()
    : super(ThemeState(mode: ThemeMode.dark, accent: AppColors.accents[0])) {
    _load();
  }

  static const _modeKey = 'theme_mode';
  static const _accentKey = 'accent_color';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_modeKey) ?? true;
    final accentValue =
        prefs.getInt(_accentKey) ?? AppColors.accents[0].toARGB32();
    emit(
      ThemeState(
        mode: isDark ? ThemeMode.dark : ThemeMode.light,
        accent: Color(accentValue),
      ),
    );
  }

  Future<void> toggleTheme() async {
    final newMode = state.mode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_modeKey, newMode == ThemeMode.dark);
    emit(state.copyWith(mode: newMode));
  }

  Future<void> setAccent(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_accentKey, color.toARGB32());
    emit(state.copyWith(accent: color));
  }
}
