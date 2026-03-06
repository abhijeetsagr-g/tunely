import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/logic/bloc/playback/playback_bloc.dart';
import 'package:tunely/ui/player/widget/album_art.dart';
import 'package:tunely/ui/player/widget/control_buttons.dart';
import 'package:tunely/ui/player/widget/seek_bar.dart';
import 'package:tunely/ui/player/widget/song_info.dart';

class PlayerView extends StatelessWidget {
  const PlayerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.watch<PlaybackBloc>().state.currentSong?.album ?? "Unknown ",
        ),
        actions: [
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (_) => BlocBuilder<PlaybackBloc, PlaybackState>(
                  buildWhen: (prev, curr) => prev.queue != curr.queue,
                  builder: (context, state) {
                    return ListView.builder(
                      itemCount: state.queue.length,
                      itemBuilder: (context, index) {
                        final tune = state.queue[index];
                        return ListTile(
                          title: Text(tune.title),
                          subtitle: Text(tune.artist),
                          leading: Text('${index + 1}'),
                          selected: tune == state.currentSong,
                          selectedColor: Colors.purple,
                        );
                      },
                    );
                  },
                ),
              );
            },
            icon: Icon(Icons.queue),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            AlbumArt(),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),
                  SongInfo(),

                  /// Seek bar
                  SeekBar(),

                  const SizedBox(height: 20),
                ],
              ),
            ),
            ControlButtons(),
          ],
        ),
      ),
    );
  }
}
