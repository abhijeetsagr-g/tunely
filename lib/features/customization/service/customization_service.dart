import 'package:flutter/material.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:tunely/core/config/app_theme.dart';
import 'package:tunely/features/customization/repository/customization_repository.dart';

class CustomizationService {
  final OnAudioQuery _query;
  final CustomizationRepository _repo;
  CustomizationService({
    required OnAudioQuery query,
    required CustomizationRepository repo,
  }) : _repo = repo,
       _query = query;

  Future<Color?> extractColors(
    int? songId, {
    Brightness brightness = Brightness.dark,
  }) => _extract(songId, ArtworkType.AUDIO, brightness);

  Future<Color?> extractAlbumColor(
    int? albumId, {
    Brightness brightness = Brightness.dark,
  }) => _extract(albumId, ArtworkType.ALBUM, brightness);

  Future<Color?> _extract(
    int? id,
    ArtworkType type,
    Brightness brightness,
  ) async {
    if (id == null) return null;
    final bytes = await _query.queryArtwork(id, type);
    if (bytes == null || bytes.isEmpty) return null;

    final palette = await PaletteGenerator.fromImageProvider(
      MemoryImage(bytes),
    );
    final raw = palette.vibrantColor?.color ?? palette.dominantColor?.color;

    return brightness == Brightness.dark
        ? _adjustForDark(raw)
        : _adjustForLight(raw);
  }

  // Dark mode — keep colors vivid, just ensure minimum lightness
  Color _adjustForDark(Color? color) {
    if (color == null) return AppTheme.lightPrimary;
    final hsl = HSLColor.fromColor(color);
    if (hsl.lightness < 0.35) return hsl.withLightness(0.35).toColor();
    if (hsl.lightness > 0.75) return hsl.withLightness(0.75).toColor();
    return color;
  }

  // Light mode — push colors darker so they're visible on light backgrounds
  Color _adjustForLight(Color? color) {
    if (color == null) return AppTheme.darkPrimary;
    final hsl = HSLColor.fromColor(color);
    if (hsl.lightness < 0.25) return hsl.withLightness(0.25).toColor();
    if (hsl.lightness > 0.45) return hsl.withLightness(0.45).toColor();
    return color;
  }

  // ThemeMode
  ThemeMode getTheme() {
    final mode = _repo.themeMode;

    return switch (mode) {
      "system" => ThemeMode.system,
      "light" => ThemeMode.light,
      _ => ThemeMode.dark,
    };
  }

  Future<void> setTheme(ThemeMode mode) => _repo.setThemeMode(switch (mode) {
    ThemeMode.system => "system",
    ThemeMode.light => "light",
    ThemeMode.dark => "dark",
  });
}
