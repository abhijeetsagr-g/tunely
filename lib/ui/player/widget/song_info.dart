import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/logic/bloc/playback/playback_bloc.dart';

class SongInfo extends StatelessWidget {
  const SongInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlaybackBloc, PlaybackState>(
      buildWhen: (prev, curr) => prev.currentSong != curr.currentSong,
      builder: (context, state) {
        final tune = state.currentSong;

        if (tune == null) return const SizedBox();

        return Column(
          children: [
            Text(
              tune.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(tune.artist, style: const TextStyle(color: Colors.grey)),
          ],
        );
      },
    );
  }
}
