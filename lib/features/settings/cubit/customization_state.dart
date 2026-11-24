part of 'customization_cubit.dart';

class CustomizationState {
  final ThemeMode themeMode;
  final Color accentColor;
  final bool useDynamic;
  final FontModel fontModel;
  final FontSizeModel fontSizeModel;

  CustomizationState({
    this.themeMode = ThemeMode.system,
    this.useDynamic = false,
    this.accentColor = AppColor.purple,
    this.fontModel = FontModel.system,
    this.fontSizeModel = FontSizeModel.medium,
  });

  CustomizationState copyWith({
    ThemeMode? themeMode,
    Color? accentColor,
    bool? useDynamic,
    FontModel? fontModel,
    FontSizeModel? fontSizeModel,
  }) {
    return CustomizationState(
      themeMode: themeMode ?? this.themeMode,
      accentColor: accentColor ?? this.accentColor,
      useDynamic: useDynamic ?? this.useDynamic,
      fontModel: fontModel ?? this.fontModel,
      fontSizeModel: fontSizeModel ?? this.fontSizeModel,
    );
  }
}
