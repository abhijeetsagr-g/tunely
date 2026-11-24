import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/features/settings/cubit/management_cubit.dart';
import 'package:tunely/features/settings/widgets/settings_slider.dart';

class DailyMixSizeSlider extends StatelessWidget {
  const DailyMixSizeSlider({super.key});

  static const _min = 10;
  static const _max = 50;
  static const _step = 5;

  @override
  Widget build(BuildContext context) {
    final size = context.select<ManagementCubit, int>(
      (c) => c.state.dailyMixSize,
    );
    final cubit = context.read<ManagementCubit>();

    return SettingsSlider(
      title: 'Daily mix size',
      value: size.clamp(_min, _max).toDouble(),
      min: _min.toDouble(),
      max: _max.toDouble(),
      divisions: (_max - _min) ~/ _step,
      format: (v) => '${v.round()} songs',
      minLabel: '$_min',
      maxLabel: '$_max',
      onCommit: (v) => cubit.updateDailyMixSize(v.round()),
    );
  }
}
