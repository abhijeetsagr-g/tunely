import 'package:flutter/material.dart';

class AppTheme {
  static const Color black = Color(0xFF0A0A0A);
  static const Color white = Color(0xFFFFFFFF);
  static const Color defaultAccent = Color(0xFF1A237E);
  static const String font = "Inter";

  static ThemeData light([Color accent = defaultAccent]) => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: white,
    primaryColor: accent,
    fontFamily: font,

    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: accent,
      onPrimary: white,
      secondary: accent,
      onSecondary: white,
      error: Colors.red,
      onError: white,
      surface: white,
      onSurface: black,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: white,
      foregroundColor: black,
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: black, size: 20),
      titleTextStyle: TextStyle(
        fontFamily: font,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: black,
      ),
    ),

    iconTheme: const IconThemeData(color: black, size: 22),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: white,
      selectedItemColor: accent,
      unselectedItemColor: const Color.fromRGBO(10, 10, 10, 0.4),
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),

    sliderTheme: SliderThemeData(
      activeTrackColor: accent,
      inactiveTrackColor: const Color.fromRGBO(10, 10, 10, 0.15),
      thumbColor: accent,
      overlayColor: accent.withAlpha(15),
      trackHeight: 2,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
      overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
      trackShape: const RoundedRectSliderTrackShape(),
    ),

    chipTheme: ChipThemeData(
      selectedColor: accent.withAlpha(15),
      checkmarkColor: accent,
      labelStyle: const TextStyle(fontFamily: font, fontSize: 13),
      side: BorderSide(color: accent.withAlpha(4)),
    ),

    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: black,
      ),
      displayMedium: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: black,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: black,
      ),
      titleMedium: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: black,
      ),
      titleSmall: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: black,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: black,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: black,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.2,
        color: black,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: black,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.3,
        color: black,
      ),
    ),
  );

  static ThemeData dark([Color accent = defaultAccent]) => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: black,
    primaryColor: accent,
    fontFamily: font,

    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: accent,
      onPrimary: white,
      secondary: accent,
      onSecondary: white,
      error: Colors.red,
      onError: white,
      surface: black,
      onSurface: white,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: black,
      foregroundColor: white,
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: white, size: 20),
      titleTextStyle: TextStyle(
        fontFamily: font,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: white,
      ),
    ),

    iconTheme: const IconThemeData(color: white, size: 22),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: black,
      selectedItemColor: accent,
      unselectedItemColor: const Color.fromRGBO(255, 255, 255, 0.4),
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),

    sliderTheme: SliderThemeData(
      activeTrackColor: accent,
      inactiveTrackColor: const Color.fromRGBO(255, 255, 255, 0.2),
      thumbColor: accent,
      overlayColor: accent.withAlpha(25),
      trackHeight: 2,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
      overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
      trackShape: const RoundedRectSliderTrackShape(),
    ),

    chipTheme: ChipThemeData(
      selectedColor: accent.withAlpha(2),
      checkmarkColor: accent,
      labelStyle: const TextStyle(fontFamily: font, fontSize: 13, color: white),
      side: BorderSide(color: accent.withAlpha(4)),
    ),

    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: white,
      ),
      displayMedium: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: white,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: white,
      ),
      titleMedium: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: white,
      ),
      titleSmall: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: white,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: white,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: white,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.2,
        color: white,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: white,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.3,
        color: white,
      ),
    ),
  );
}
