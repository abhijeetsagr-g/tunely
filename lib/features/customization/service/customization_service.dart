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

    // Downscale before extracting so the palette reflects broad regions
    // instead of fine pixel noise, and decode stays cheap.
    final palette = await PaletteGenerator.fromImageProvider(
      ResizeImage.resizeIfNeeded(256, 256, MemoryImage(bytes)),
      maximumColorCount: 24,
    );
    final raw = _pickPaletteColor(palette.paletteColors);

    return brightness == Brightness.dark
        ? _adjustForDark(raw)
        : _adjustForLight(raw);
  }

  // Prefer common colors, nudged toward moderate saturation/lightness, so the
  // result is representative of the artwork rather than a rare flashy swatch.
  Color _pickPaletteColor(List<PaletteColor> colors) {
    if (colors.isEmpty) return Colors.blueAccent;
    final dominant = colors.first.population;
    PaletteColor best = colors.first;
    var bestScore = double.negativeInfinity;
    for (final color in colors) {
      final hsl = HSLColor.fromColor(color.color);
      final populationScore = color.population / dominant;
      final saturationScore = 1 - (hsl.saturation - 0.45).abs();
      final lightnessScore = 1 - (hsl.lightness - 0.5).abs();
      final score =
          populationScore * 0.55 +
          saturationScore * 0.30 +
          lightnessScore * 0.15;
      if (score > bestScore) {
        bestScore = score;
        best = color;
      }
    }
    return best.color;
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
