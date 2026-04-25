import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/features/customization/service/color_service.dart';

class CustomizationCubit extends Cubit<CustomizationState> {
  final ColorService _colorCustomizer;

  CustomizationCubit(this._colorCustomizer) : super(CustomizationState());

  Future<Color?> extractColors(
    int? songId, {
    Brightness brightness = Brightness.dark,
  }) => _colorCustomizer.extractColors(songId, brightness: brightness);
}

class CustomizationState {}
