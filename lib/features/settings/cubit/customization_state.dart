part of 'customization_cubit.dart';

class CustomizationState {
  final ThemeMode themeMode;
  final Color accentColor;
  final bool useDynamic;

  CustomizationState({
    this.themeMode = ThemeMode.system,
    this.useDynamic = false,
    this.accentColor = AppColor.purple,
  });

  CustomizationState copyWith({
    ThemeMode? themeMode,
    Color? accentColor,
    bool? useDynamic,
  }) {
    return CustomizationState(
      themeMode: themeMode ?? this.themeMode,
      accentColor: accentColor ?? this.accentColor,
      useDynamic: useDynamic ?? this.useDynamic,
    );
  }
}
