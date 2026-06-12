import 'package:flutter/material.dart';

abstract class AppTheme {
  static const String font = "NunitoSans";
  static const Color black = Color(0xFF0A0A0A);
  static const Color white = Color(0xFFFFFFFF);
  static const Color defaultAccent = Color(0xffB3E0F2);
  static const Color warmAccent = Color(0xFFFFB347);
  static const Color roseAccent = Color(0xFFF2B3C6);

  // Light
  static const Color lightBg = Color(0xFFE9E3E6);
  static const Color lightSurface = Color(0xFFC3BABA);
  static const Color lightPrimary = Color(0xFF9A8F97);
  static const Color lightSecondary = Color(0xFFB2B2B2);
  static const Color lightOnSurface = Color(0xFF423E41);
  static const Color lightOnSurfaceVariant = Color(0xFF736F72);

  // Dark
  static const Color darkBg = Color(0xFF181617);
  static const Color darkSurface = Color(0xFF282427);
  static const Color darkPrimary = Color(0xFF9A8F97);
  static const Color darkSecondary = Color(0xFF736F72);
  static const Color darkOnSurface = Color(0xFFE9E3E6);
  static const Color darkOnSurfaceVariant = Color(0xFFC3BABA);

  // Animations
  static const Curve enter = Cubic(0.05, 0.7, 0.1, 1); // md3Decel
  static const Curve exit = Cubic(0.3, 0, 0.8, 0.15); // md3Accel
  static const Duration enterDuration = Duration(milliseconds: 200);
  static const Duration exitDuration = Duration(milliseconds: 150);
  static const Duration expandDuration = Duration(
    milliseconds: 300,
  ); // mini → player

  static ThemeData dark({Color accent = darkPrimary}) => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBg,
    primaryColor: darkPrimary,
    colorScheme: ColorScheme.dark(
      primary: darkPrimary,
      secondary: darkSecondary,
      surface: darkSurface,
      onPrimary: darkOnSurface,
      onSurface: darkOnSurface,
      onSurfaceVariant: darkOnSurfaceVariant,
    ),
    fontFamily: font,
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    iconTheme: IconThemeData(color: darkOnSurface),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedIconTheme: IconThemeData(color: darkPrimary),
      unselectedIconTheme: IconThemeData(color: darkOnSurface),
      selectedItemColor: darkPrimary,
      unselectedItemColor: darkOnSurface,
    ),
    sliderTheme: _sliderTheme(darkPrimary, darkSecondary),
  );

  static ThemeData light({Color accent = lightPrimary}) => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: lightBg,
    primaryColor: accent,
    colorScheme: ColorScheme.light(
      primary: lightPrimary,
      secondary: lightSecondary,
      surface: lightSurface,
      onPrimary: white,
      onSurface: lightOnSurface,
      onSurfaceVariant: lightOnSurfaceVariant,
    ),
    fontFamily: font,
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    iconTheme: IconThemeData(color: lightOnSurface),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedIconTheme: IconThemeData(color: lightPrimary),
      unselectedIconTheme: IconThemeData(color: lightOnSurface),
      selectedItemColor: lightPrimary,
      unselectedItemColor: lightOnSurface,
    ),
    sliderTheme: _sliderTheme(lightPrimary, lightSecondary),
  );

  static SliderThemeData _sliderTheme(Color accent, Color base) {
    return SliderThemeData(
      trackHeight: 4,
      activeTrackColor: accent,
      inactiveTrackColor: base,
      thumbColor: accent,
      overlayColor: accent.withAlpha(15),
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
      overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
      trackShape: const RoundedRectSliderTrackShape(),
    );
  }
}
