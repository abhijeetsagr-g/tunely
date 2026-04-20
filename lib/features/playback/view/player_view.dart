import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/features/playback/bloc/playback_bloc.dart';
import 'package:tunely/features/playback/view/widget/control_button.dart';
import 'package:tunely/features/playback/view/widget/next_song_label.dart';
import 'package:tunely/features/playback/view/widget/player_album_art.dart';
import 'package:tunely/features/playback/view/widget/player_gradient_background.dart';
import 'package:tunely/features/playback/view/widget/seek_bar.dart';
import 'package:tunely/features/playback/view/widget/song_info.dart';

class PlayerView extends StatelessWidget {
  const PlayerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          const PlayerGradientBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 30,
                children: [
                  _PlayerAppBar(),
                  PlayerAlbumArt(),
                  SongInfo(),
                  SeekBar(),
                  ControlButtons(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => BlocProvider.value(
                            value: context.read<PlaybackBloc>(),
                            // child: const QueueSheet(),
                          ),
                        ),
                        icon: const Icon(Icons.queue_music_outlined),
                      ),
                      SizedBox(width: 250, child: NextSongLabel()),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.lyrics_outlined),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayerAppBar extends StatelessWidget {
  const _PlayerAppBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.keyboard_arrow_down),
        ),
        BlocBuilder<PlaybackBloc, PlaybackState>(
          builder: (context, state) {
            if (state.currentItem == null) return const SizedBox();
            return Expanded(
              child: Center(
                child: Text(
                  state.currentItem?.album ?? "Album Name",
                  style: Theme.of(context).textTheme.labelLarge,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            );
          },
        ),
        const SizedBox(width: 48),
      ],
    );
  }
}
