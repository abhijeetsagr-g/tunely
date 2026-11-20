import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/core/config/app_color.dart';
import 'package:tunely/features/settings/service/customization_service.dart';

part 'customization_state.dart';

class CustomizationCubit extends Cubit<CustomizationState> {
  final CustomizationService _colorCustomizer;

  CustomizationCubit(this._colorCustomizer)
    : super(
        CustomizationState(
          themeMode: _colorCustomizer.getTheme(),
          accentColor: _colorCustomizer.getAccentColor(),
          useDynamic: false,
        ),
      );

  Future<void> setThemeMode(ThemeMode mode) async {
    await _colorCustomizer.setTheme(mode);
    emit(state.copyWith(themeMode: mode));
  }

  void setAccentColor(Color color) =>
      emit(state.copyWith(accentColor: color, useDynamic: false));

  void setUseDynamic(bool value) => emit(state.copyWith(useDynamic: value));

  Future<Color?> extractColors(
    int? songId, {
    Brightness brightness = Brightness.dark,
  }) => _colorCustomizer.extractColors(songId, brightness: brightness);

  Future<Color?> extractAlbumColor(
    int? albumId, {
    Brightness brightness = Brightness.dark,
  }) => _colorCustomizer.extractAlbumColor(albumId, brightness: brightness);
}
