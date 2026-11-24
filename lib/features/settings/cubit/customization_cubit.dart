import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/core/config/app_color.dart';
import 'package:tunely/features/settings/model/font_model.dart';
import 'package:tunely/features/settings/service/customization_service.dart';

part 'customization_state.dart';

class CustomizationCubit extends Cubit<CustomizationState> {
  final CustomizationService _customizer;

  CustomizationCubit(this._customizer)
    : super(
        CustomizationState(
          themeMode: _customizer.getTheme(),
          accentColor: _customizer.getAccentColor(),
          useDynamic: false,
          fontModel: _customizer.getFont(),
        ),
      );

  Future<void> setThemeMode(ThemeMode mode) async {
    await _customizer.setTheme(mode);
    emit(state.copyWith(themeMode: mode));
  }

  Future<void> setAccentColor(Color color) async {
    await _customizer.setAccentColor(color);
    emit(state.copyWith(accentColor: color, useDynamic: false));
  }

  void setUseDynamic(bool value) {
    emit(state.copyWith(useDynamic: value));
  }

  Future<void> setFontFamily(FontModel fontModel) async {
    await _customizer.setFont(fontModel);
    emit(state.copyWith(fontModel: fontModel));
  }

  Future<Color?> extractColors(
    int? songId, {
    Brightness brightness = Brightness.dark,
  }) => _customizer.extractColors(songId, brightness: brightness);

  Future<Color?> extractAlbumColor(
    int? albumId, {
    Brightness brightness = Brightness.dark,
  }) => _customizer.extractAlbumColor(albumId, brightness: brightness);
}
