import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:tunely/features/player/cubit/now_playing_state.dart';
import 'package:tunely/features/theme/theme_cubit.dart';

class NowPlayingCubit extends Cubit<NowPlayingState> {
  final OnAudioQuery _query = OnAudioQuery();
  final ThemeCubit _theme;

  NowPlayingCubit(this._theme) : super(NowPlayingState());

  Future<void> extractColors(int? songId) async {
    if (songId == null) return;

    final bytes = await _query.queryArtwork(
      songId,
      ArtworkType.AUDIO,
      quality: 50,
    );

    if (bytes == null || bytes.isEmpty) return;

    final palette = await PaletteGenerator.fromImageProvider(
      MemoryImage(bytes),
    );

    final raw =
        palette.vibrantColor?.color ??
        palette.dominantColor?.color ??
        _theme.state.accent;

    final color = _ensureMinLightness(raw, minLightness: 0.45);
    await _theme.setAccent(color);
  }

  Color _ensureMinLightness(Color color, {double minLightness = 0.45}) {
    final hsl = HSLColor.fromColor(color);
    if (hsl.lightness >= minLightness) return color;
    return hsl.withLightness(minLightness).toColor();
  }
}
