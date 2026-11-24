import 'package:flutter/material.dart';
import 'package:tunely/features/settings/model/font_model.dart';
import 'package:tunely/features/settings/model/font_size_model.dart';

abstract class AppTheme {
  static const Color white = Color(0xFFFFFFFF);
  static const Color primary = Color(0xFF8070A4);

  // Light
  static const Color lightBg = Color(0xFFE9E3E6);
  static const Color lightSurface = Color(0xFFC3BABA);
  static const Color lightPrimary = primary;
  static const Color lightSecondary = Color(0xFFB2B2B2);
  static const Color lightOnSurface = Color(0xFF423E41);
  static const Color lightOnSurfaceVariant = Color(0xFF736F72);

  // Dark
  static const Color darkBg = Color(0xFF181617);
  static const Color darkSurface = Color(0xFF282427);
  static const Color darkPrimary = primary;
  static const Color darkSecondary = Color(0xFF736F72);
  static const Color darkOnSurface = Color(0xFFE9E3E6);
  static const Color darkOnSurfaceVariant = Color(0xFFC3BABA);

  // Animations
  static const Curve enter = Cubic(0.05, 0.7, 0.1, 1); // md3Decel
  static const Curve exit = Cubic(0.3, 0, 0.8, 0.15); // md3Accel
  static const Duration enterDuration = Duration(milliseconds: 300);
  static const Duration exitDuration = Duration(milliseconds: 150);
  static const Duration gradientDuration = Duration(milliseconds: 600);
  static const Duration expandDuration = Duration(
    milliseconds: 300,
  ); // mini → player

  // Staggered list reveals
  static const Duration revealDuration = Duration(milliseconds: 180);
  static const Duration revealDelayStep = Duration(milliseconds: 24);

  static ThemeData dark({
    Color accent = darkPrimary,
    FontModel fontName = FontModel.system,
    FontSizeModel fontSize = FontSizeModel.medium,
  }) => ThemeData(
    brightness: Brightness.dark,

    scaffoldBackgroundColor: darkBg,
    primaryColor: accent,
    colorScheme: ColorScheme.dark(
      primary: accent,
      secondary: darkSecondary,
      surface: darkSurface,
      onPrimary: darkOnSurface,
      onSurface: darkOnSurface,
      onSurfaceVariant: darkOnSurfaceVariant,
    ),

    textTheme: _textTheme(darkOnSurface, fontName, fontSize),
    fontFamily: fontName.family,
    splashColor: accent.withAlpha(20),
    highlightColor: accent.withAlpha(10),
    iconTheme: IconThemeData(color: darkOnSurface),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedIconTheme: IconThemeData(color: accent),
      unselectedIconTheme: IconThemeData(color: darkOnSurface),
      selectedItemColor: accent,
      unselectedItemColor: darkOnSurface,
    ),
    sliderTheme: _sliderTheme(accent, darkSecondary),
  );

  static ThemeData light({
    Color accent = lightPrimary,
    FontModel fontName = FontModel.system,
    FontSizeModel fontSize = FontSizeModel.medium,
  }) => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: lightBg,
    primaryColor: accent,
    colorScheme: ColorScheme.light(
      primary: accent,
      secondary: lightSecondary,
      surface: lightSurface,
      onPrimary: white,
      onSurface: lightOnSurface,
      onSurfaceVariant: lightOnSurfaceVariant,
    ),
    fontFamily: fontName.family,
    textTheme: _textTheme(lightOnSurface, fontName, fontSize),
    splashColor: accent.withAlpha(20),
    highlightColor: accent.withAlpha(10),
    iconTheme: IconThemeData(color: lightOnSurface),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedIconTheme: IconThemeData(color: accent),
      unselectedIconTheme: IconThemeData(color: lightOnSurface),
      selectedItemColor: accent,
      unselectedItemColor: lightOnSurface,
    ),
    sliderTheme: _sliderTheme(accent, lightSecondary),
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

  /// App-wide type scale.
  static TextTheme _textTheme(
    Color onSurface,
    FontModel fontName,
    FontSizeModel fontSizeModel,
  ) {
    final TextTheme base = Typography.material2021().black;

    TextStyle? style(
      TextStyle? textStyle, {
      required double fontSize,
      FontWeight fontWeight = FontWeight.w400,
    }) => textStyle?.copyWith(
      fontSize: fontSize * fontSizeModel.scale,
      fontWeight: fontWeight,
      color: onSurface,
    );

    return TextTheme(
      // Page titles: Library, Search, Tunely, Settings
      headlineLarge: style(
        base.headlineLarge,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),

      // Album title, section headers (Top Songs, Daily Mix)
      titleLarge: style(
        base.titleLarge,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),

      // Song titles
      titleMedium: style(
        base.titleMedium,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),

      // Song Artists/Album Etc
      titleSmall: style(base.titleSmall, fontSize: 12),

      // Lyrics lines
      bodyLarge: style(base.bodyLarge, fontSize: 18),

      // Artist names under songs
      bodyMedium: style(base.bodyMedium, fontSize: 14),

      // Timestamps, plays count, descriptions
      bodySmall: style(base.bodySmall, fontSize: 12),

      // Buttons, chips (Name / Date Added / Duration)
      labelLarge: style(
        base.labelLarge,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),

      // Nav bar labels
      labelMedium: style(base.labelMedium, fontSize: 11),
    ).apply(fontFamily: fontName.family);
  }
}
