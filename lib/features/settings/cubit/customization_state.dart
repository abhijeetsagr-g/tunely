part of 'customization_cubit.dart';

class CustomizationState {
  final ThemeMode themeMode;
  final Color accentColor;

  CustomizationState({
    this.themeMode = ThemeMode.system,
    this.accentColor = AppColor.purple,
  });

  CustomizationState copyWith({ThemeMode? themeMode, Color? accentColor}) {
    return CustomizationState(
      themeMode: themeMode ?? this.themeMode,
      accentColor: accentColor ?? this.accentColor,
    );
  }
}
