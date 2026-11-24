import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/features/settings/cubit/management_cubit.dart';
import 'package:tunely/features/settings/widgets/settings_slider.dart';

class MinSongDurSlider extends StatelessWidget {
  const MinSongDurSlider({super.key});

  // Positions 0-30 = 0-30s in 1s steps, 31-36 = 35-60s in 5s steps.
  static const _maxPos = 36.0;

  static double _msToPos(int ms) {
    final sec = ms ~/ 1000;
    if (sec <= 30) return sec.toDouble();
    return (30 + (sec - 30) / 5).clamp(30.0, _maxPos).toDouble();
  }

  static int _posToMs(double pos) {
    if (pos <= 30) return pos.round() * 1000;
    return (30 + ((pos - 30) * 5).round()) * 1000;
  }

  static String _format(int ms) {
    if (ms == 0) return 'Off';
    final sec = ms ~/ 1000;
    if (sec < 60) return '${sec}s';
    return sec % 60 == 0 ? '${sec ~/ 60}m' : '${sec ~/ 60}m ${sec % 60}s';
  }

  @override
  Widget build(BuildContext context) {
    final ms = context.select<ManagementCubit, int>(
      (c) => c.state.minDurationMs,
    );
    final cubit = context.read<ManagementCubit>();

    return SettingsSlider(
      title: 'Minimum song duration',
      value: _msToPos(ms),
      min: 0,
      max: _maxPos,
      divisions: _maxPos.toInt(),
      format: (pos) => _format(_posToMs(pos)),
      minLabel: 'Off',
      maxLabel: '1m',
      caption: 'Shorter songs are hidden from your library.',
      onCommit: (pos) => cubit.updateMinDuration(_posToMs(pos)),
    );
  }
}
