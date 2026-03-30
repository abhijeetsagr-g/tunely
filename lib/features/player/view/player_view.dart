import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/core/const/app_route.dart';
import 'package:tunely/core/extensions/title_case.dart';
import 'package:tunely/data/model/tune.dart';
import 'package:tunely/features/lyrics/view/lyrics_view.dart';
import 'package:tunely/features/player/bloc/playback_bloc.dart';
import 'package:tunely/features/player/view/widget/control_buttons.dart';
import 'package:tunely/features/player/view/widget/next_song_label.dart';
import 'package:tunely/features/player/view/widget/player_album_art.dart';
import 'package:tunely/features/player/view/widget/seek_bar.dart';
import 'package:tunely/features/player/view/widget/show_sleeper_timer.dart';
import 'package:tunely/features/player/view/widget/song_info.dart';

class PlayerView extends StatelessWidget {
  const PlayerView({super.key});

  AppBar _appBar(BuildContext context) => AppBar(
    centerTitle: true,
    actions: [
      IconButton(
        onPressed: () => showSleepTimerSheet(context),
        icon: const Icon(Icons.timer_outlined),
      ),
    ],
    title: BlocSelector<PlaybackBloc, PlaybackState, Tune?>(
      selector: (state) => state.currentSong,
      builder: (context, tune) => InkWell(
        onTap: () {
          if (tune != null) {
            Navigator.pushReplacementNamed(
              context,
              AppRoute.album,
              arguments: tune.albumId,
            );
          }
        },
        child: Text(
          tune?.album.toTitleCase() ?? "Unknown",
          style: Theme.of(context).textTheme.titleLarge,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
    ),
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
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, AppRoute.lyrics),
              child: PlayerAlbumArt(),
            ),
            SongInfo(),
            SeekBar(),
            ControlButtons(),
            NextSongLabel(),
          ],
        ),
      ),
    );
  }
}
