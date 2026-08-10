part of 'customization_cubit.dart';

class CustomizationState {
  final ThemeMode themeMode;

  CustomizationState({this.themeMode = ThemeMode.system});

  CustomizationState copyWith({ThemeMode? themeMode}) {
    return CustomizationState(themeMode: themeMode ?? this.themeMode);
  }
}
