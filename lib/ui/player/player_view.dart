import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/core/extensions/title_case.dart';
import 'package:tunely/logic/provider/playback/playback_bloc.dart';
import 'package:tunely/ui/player/widget/next_song_label.dart';
import 'package:tunely/ui/player/widget/player_album_art.dart';
import 'package:tunely/ui/player/widget/control_buttons.dart';
import 'package:tunely/ui/player/widget/seek_bar.dart';
import 'package:tunely/ui/player/widget/song_info.dart';

class PlayerView extends StatelessWidget {
  const PlayerView({super.key});

  AppBar _appBar(BuildContext context) => AppBar(
    // leading: SizedBox(),
    centerTitle: true,
    title: BlocSelector<PlaybackBloc, PlaybackState, String>(
      selector: (state) => state.currentSong?.album ?? "Unknown",
      builder: (context, album) => Text(
        album.toTitleCase(),
        style: Theme.of(context).textTheme.titleLarge,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
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
            PlayerAlbumArt(),
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
