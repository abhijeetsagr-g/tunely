import 'package:flutter/material.dart';

class AppTheme {
  static const primary = Color(0xFF1A237E);

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
      inactiveTrackColor: Color.fromRGBO(10, 10, 10, 0.15),
      thumbColor: primary,
      overlayColor: Color.fromRGBO(26, 35, 126, 0.15),
      trackHeight: 3,
    ),
  );

  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: black,
    primaryColor: primary,
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
      activeTrackColor: primary,
      inactiveTrackColor: Color.fromRGBO(255, 255, 255, 0.2),
      thumbColor: primary,
      overlayColor: Color.fromRGBO(26, 35, 126, 0.25),
      trackHeight: 3,
    ),
  );
}
