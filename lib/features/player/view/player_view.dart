import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/core/const/app_route.dart';
import 'package:tunely/features/player/bloc/playback_bloc.dart';
import 'package:tunely/features/player/view/widget/control_buttons.dart';
import 'package:tunely/features/player/view/widget/next_song_label.dart';
import 'package:tunely/features/player/view/widget/player_album_art.dart';
import 'package:tunely/features/player/view/widget/queue_sheet.dart';
import 'package:tunely/features/player/view/widget/seek_bar.dart';
import 'package:tunely/features/player/view/widget/show_sleeper_timer.dart';
import 'package:tunely/features/player/view/widget/song_info.dart';

class PlayerView extends StatelessWidget {
  const PlayerView({super.key});
  AppBar _appBar(BuildContext context) => AppBar(
    centerTitle: true,
    leading: IconButton(
      onPressed: () {
        Navigator.pop(context);
      },
      icon: Icon(Icons.keyboard_arrow_down),
    ),
    title: BlocBuilder<PlaybackBloc, PlaybackState>(
      builder: (context, state) {
        if (state.currentSong == null) return SizedBox();

        return InkWell(
          onTap: () => Navigator.pushNamed(
            context,
            AppRoute.album,
            arguments: state.currentSong?.albumId,
          ),

          child: Text(
            state.currentSong?.album ?? "Album Name",
            style: Theme.of(context).textTheme.labelLarge,
            textAlign: TextAlign.center,
            maxLines: 1,
          ),
        );
      },
    ),
    actions: [
      IconButton(
        onPressed: () => showSleepTimerSheet(context),
        icon: const Icon(Icons.mode_night_outlined, size: 20),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(context),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 30,
          children: [
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
                      child: const QueueSheet(),
                    ),
                  ),
                  icon: Icon(Icons.queue_music_outlined),
                ),
                NextSongLabel(),
                IconButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoute.lyrics),
                  icon: Icon(Icons.lyrics_outlined),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
