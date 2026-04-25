import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/features/customization/service/customization_service.dart';

part 'customization_state.dart';

class CustomizationCubit extends Cubit<CustomizationState> {
  final CustomizationService _colorCustomizer;

  CustomizationCubit(this._colorCustomizer)
    : super(CustomizationState(themeMode: _colorCustomizer.getTheme()));

  Future<void> setThemeMode(ThemeMode mode) async {
    await _colorCustomizer.setTheme(mode);
    emit(state.copyWith(themeMode: mode));
  }

  Future<Color?> extractColors(
    int? songId, {
    Brightness brightness = Brightness.dark,
  }) => _colorCustomizer.extractColors(songId, brightness: brightness);
}
