part of 'customization_cubit.dart';

class CustomizationState {
  final ThemeMode themeMode;
  final Color accentColor;
  final bool useDynamic;
  final FontModel fontModel;

  CustomizationState({
    this.themeMode = ThemeMode.system,
    this.useDynamic = false,
    this.accentColor = AppColor.purple,
    this.fontModel = FontModel.system,
  });

  CustomizationState copyWith({
    ThemeMode? themeMode,
    Color? accentColor,
    bool? useDynamic,
    FontModel? fontModel,
  }) {
    return CustomizationState(
      themeMode: themeMode ?? this.themeMode,
      accentColor: accentColor ?? this.accentColor,
      useDynamic: useDynamic ?? this.useDynamic,
      fontModel: fontModel ?? this.fontModel,
    );
  }
}
