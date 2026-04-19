import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:palette_generator/palette_generator.dart';

class ColorCustomizer {
  final OnAudioQuery _query;
  ColorCustomizer({required OnAudioQuery query}) : _query = query;

  Future<Color?> extractColors(
    int? songId, {
    Brightness brightness = Brightness.dark,
  }) async {
    if (songId == null) return null;
    final bytes = await _query.queryArtwork(songId, ArtworkType.AUDIO);
    if (bytes == null || bytes.isEmpty) return null;

    final palette = await PaletteGenerator.fromImageProvider(
      MemoryImage(bytes),
    );
    final raw =
        palette.vibrantColor?.color ??
        palette.dominantColor?.color ??
        Colors.blueAccent;

    return brightness == Brightness.dark
        ? _adjustForDark(raw)
        : _adjustForLight(raw);
  }

  // Dark mode — keep colors vivid, just ensure minimum lightness
  Color _adjustForDark(Color color) {
    final hsl = HSLColor.fromColor(color);
    if (hsl.lightness < 0.35) return hsl.withLightness(0.35).toColor();
    if (hsl.lightness > 0.75) return hsl.withLightness(0.75).toColor();
    return color;
  }

  // Light mode — push colors darker so they're visible on light backgrounds
  Color _adjustForLight(Color color) {
    final hsl = HSLColor.fromColor(color);
    if (hsl.lightness < 0.25) return hsl.withLightness(0.25).toColor();
    if (hsl.lightness > 0.45) return hsl.withLightness(0.45).toColor();
    return color;
  }
}
