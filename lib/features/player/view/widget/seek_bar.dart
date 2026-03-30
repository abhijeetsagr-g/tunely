import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/core/utlis/fur_duration.dart';
import 'package:tunely/features/player/bloc/playback_bloc.dart';

class SeekBar extends StatefulWidget {
  const SeekBar({super.key});

  @override
  State<SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends State<SeekBar> {
  double? _dragValue;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlaybackBloc, PlaybackState>(
      buildWhen: (prev, curr) => prev.pos != curr.pos || prev.dur != curr.dur,
      builder: (context, state) {
        final max = state.dur.inMilliseconds.toDouble();
        final value = (_dragValue ?? state.pos.inMilliseconds.toDouble())
            .clamp(0, max.isNaN || max == 0 ? 1 : max)
            .toDouble();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              Slider(
                min: 0,
                max: max == 0 ? 1 : max,
                value: value,
                onChanged: (v) => setState(() => _dragValue = v),
                onChangeEnd: (v) {
                  context.read<PlaybackBloc>().add(
                    Seek(Duration(milliseconds: v.toInt())),
                  );
                  setState(() => _dragValue = null);
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    formatDur(Duration(milliseconds: value.toInt())),
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  Text(
                    formatDur(state.dur),
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
