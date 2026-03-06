import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/logic/bloc/playback/playback_bloc.dart';

class SeekBar extends StatelessWidget {
  const SeekBar({super.key});

  String _format(Duration d) {
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlaybackBloc, PlaybackState>(
      buildWhen: (prev, curr) => prev.pos != curr.pos || prev.dur != curr.dur,
      builder: (context, state) {
        return Column(
          children: [
            Slider(
              min: 0,
              max: state.dur.inMilliseconds.toDouble(),
              value: state.pos.inMilliseconds
                  .clamp(0, state.dur.inMilliseconds)
                  .toDouble(),
              onChanged: (value) {
                context.read<PlaybackBloc>().add(
                  Seek(Duration(milliseconds: value.toInt())),
                );
              },
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text(_format(state.pos)), Text(_format(state.dur))],
            ),
          ],
        );
      },
    );
  }
}
