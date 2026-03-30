import 'package:flutter/material.dart';

class ThemeState {
  final ThemeMode mode;
  final Color accent;

  const ThemeState({required this.mode, required this.accent});

  ThemeState copyWith({ThemeMode? mode, Color? accent}) =>
      ThemeState(mode: mode ?? this.mode, accent: accent ?? this.accent);
}
