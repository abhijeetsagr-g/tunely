import 'package:flutter/material.dart';

abstract class AppTheme {
  static const String font = "Manrope";
  static const Color black = Color(0xFF0A0A0A);
  static const Color white = Color(0xFFFFFFFF);
  static const Color defaultAccent = Colors.purple;

  // Animations
  static const Curve enter = Cubic(0.05, 0.7, 0.1, 1); // md3Decel
  static const Curve exit = Cubic(0.3, 0, 0.8, 0.15); // md3Accel
  static const Duration enterDuration = Duration(milliseconds: 200);
  static const Duration exitDuration = Duration(milliseconds: 150);
  static const Duration expandDuration = Duration(
    milliseconds: 300,
  ); // mini → player

  static ThemeData dark({Color accent = defaultAccent}) => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: black,
    primaryColor: accent,
    colorScheme: ColorScheme.dark(
      primary: accent,
      surface: black,
      onPrimary: white,
      onSurface: white,
    ),
    fontFamily: font,
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    iconTheme: IconThemeData(color: accent),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedIconTheme: IconThemeData(color: accent),
      unselectedIconTheme: IconThemeData(color: white),
      selectedItemColor: accent,
      unselectedItemColor: Colors.white,
    ),

    sliderTheme: _sliderTheme(accent, Colors.grey),
  );

  static ThemeData light({Color accent = defaultAccent}) => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: white,
    primaryColor: accent,
    colorScheme: ColorScheme.light(
      primary: accent,
      surface: white,
      onPrimary: black,
      onSurface: black,
    ),
    fontFamily: font,
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    iconTheme: IconThemeData(color: accent),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedIconTheme: IconThemeData(color: accent),
      unselectedIconTheme: IconThemeData(color: black),
      selectedItemColor: accent,
      unselectedItemColor: Colors.black,
    ),
    sliderTheme: _sliderTheme(accent, Colors.grey),
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
