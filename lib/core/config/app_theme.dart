import 'package:flutter/material.dart';

class AppTheme {
  static const primary = Color(0xFF1A237E);
  static const primaryLight = Color(0xFF534BAE);
  static const black = Color(0xFF0A0A0A);
  static const white = Color(0xFFFFFFFF);

  static const font = "Inter";

  static ThemeData get light => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: white,
    primaryColor: primary,
    fontFamily: font,

    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: primary,
      onPrimary: white,
      secondary: primary,
      onSecondary: white,
      error: Colors.red,
      onError: white,
      surface: white,
      onSurface: black,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: white,
      foregroundColor: black,
      iconTheme: IconThemeData(color: black, size: 20),
      titleTextStyle: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: black,
      ),
    ),

    iconTheme: const IconThemeData(color: black, size: 22),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: white,
      selectedItemColor: primary,
      unselectedItemColor: Color.fromRGBO(10, 10, 10, 0.6),
      type: BottomNavigationBarType.fixed,
    ),

    sliderTheme: const SliderThemeData(
      activeTrackColor: primary,
      thumbColor: primary,
      inactiveTrackColor: Color.fromRGBO(10, 10, 10, 0.15),
      overlayColor: Color.fromRGBO(26, 35, 126, 0.15),
      trackHeight: 2,

      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 5),
      overlayShape: RoundSliderOverlayShape(overlayRadius: 14),
      trackShape: RoundedRectSliderTrackShape(),
    ),

    textTheme: const TextTheme(
      // Large titles — Splash, section headers
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),

      // AppBar title, page titles
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
      titleMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),

      // Song title in PlayerView, card titles
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      // Artist name, subtitles
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
      // Small labels — "Next: song name", timestamps
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.2,
      ),

      // Buttons, chips, dropdowns
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.3,
      ),
    ),
  );

  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: black,
    primaryColor: primaryLight,
    fontFamily: font,

    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: primary,
      onPrimary: white,
      secondary: primary,
      onSecondary: white,
      error: Colors.red,
      onError: white,
      surface: black,
      onSurface: white,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: black,
      foregroundColor: white,
      iconTheme: IconThemeData(color: white, size: 20),
      titleTextStyle: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: white,
      ),
    ),

    iconTheme: const IconThemeData(color: white, size: 22),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: black,
      selectedItemColor: primary,
      unselectedItemColor: Color.fromRGBO(255, 255, 255, 0.6),
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),

    sliderTheme: const SliderThemeData(
      activeTrackColor: primaryLight,
      inactiveTrackColor: Color.fromRGBO(255, 255, 255, 0.2),
      thumbColor: primaryLight,
      overlayColor: Color.fromRGBO(26, 35, 126, 0.25),
      trackHeight: 2,

      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 5),
      overlayShape: RoundSliderOverlayShape(overlayRadius: 14),
      trackShape: RoundedRectSliderTrackShape(),
    ),

    textTheme: const TextTheme(
      // Large titles — Splash, section headers
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),

      // AppBar title, page titles
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
      titleMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),

      // Song title in PlayerView, card titles
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      // Artist name, subtitles
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
      // Small labels — "Next: song name", timestamps
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.2,
      ),

      // Buttons, chips, dropdowns
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.3,
      ),
    ),
  );
}
