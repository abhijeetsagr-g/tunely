import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/core/config/app_route.dart';
import 'package:tunely/core/extensions/title_case.dart';
import 'package:tunely/logic/provider/playback/playback_bloc.dart';
import 'package:tunely/logic/provider/query/query_cubit.dart';
import 'package:tunely/ui/player/widget/next_song_label.dart';
import 'package:tunely/ui/player/widget/player_album_art.dart';
import 'package:tunely/ui/player/widget/control_buttons.dart';
import 'package:tunely/ui/player/widget/seek_bar.dart';
import 'package:tunely/ui/player/widget/show_sleeper_timer.dart';
import 'package:tunely/ui/player/widget/song_info.dart';

class PlayerView extends StatelessWidget {
  const PlayerView({super.key});

  void _onAlbumTap(BuildContext context) {
    final state = context.read<PlaybackBloc>().state;
    final currentSong = state.currentSong;
    if (currentSong == null || currentSong.albumId == null) return;

    final album = context.read<QueryCubit>().getAlbumById(currentSong.albumId!);
    if (album == null) return;

    final tunes = state.queue
        .where((t) => t.albumId == currentSong.albumId)
        .toList();

    Navigator.pushNamed(
      context,
      AppRoutes.album,
      arguments: AlbumViewArgs(album: album, tunes: tunes),
    );
  }

  AppBar _appBar(BuildContext context) => AppBar(
    centerTitle: true,
    actions: [
      IconButton(
        onPressed: () => showSleepTimerSheet(context),
        icon: const Icon(Icons.timer_outlined),
      ),
    ],
    title: BlocSelector<PlaybackBloc, PlaybackState, String>(
      selector: (state) => state.currentSong?.album ?? "Unknown",
      builder: (context, album) => GestureDetector(
        onTap: () => _onAlbumTap(context),
        child: Text(
          album.toTitleCase(),
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
