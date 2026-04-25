import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/core/const/app_route.dart';
import 'package:tunely/core/utlis/settings_arguments.dart';
import 'package:tunely/features/library/cubit/library_cubit.dart';
import 'package:tunely/features/playback/bloc/playback_bloc.dart';
import 'package:tunely/features/playback/view/widget/control_button.dart';
import 'package:tunely/features/playback/view/widget/next_song_label.dart';
import 'package:tunely/features/playback/view/widget/player_album_art.dart';
import 'package:tunely/features/playback/view/widget/player_gradient_background.dart';
import 'package:tunely/features/playback/view/widget/seek_bar.dart';
import 'package:tunely/features/playback/view/widget/song_info.dart';
import 'package:tunely/features/sleep_mode/view/sleep_sheet.dart';

class PlayerView extends StatelessWidget {
  const PlayerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoute.queue);
                        },
                        icon: const Icon(Icons.queue_music_outlined),
                      ),
                      SizedBox(width: 250, child: NextSongLabel()),
                      IconButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoute.lyrics);
                        },
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
          buildWhen: (prev, curr) => prev.currentItem != curr.currentItem,
          builder: (context, state) {
            if (state.currentItem == null) return const SizedBox();
            return Expanded(
              child: InkWell(
                onTap: () {
                  final loaded =
                      context.read<LibraryCubit>().state as LibraryLoaded;
                  final album = loaded.albums.firstWhereOrNull(
                    (e) => e.id == state.currentItem?.albumId,
                  );
                  if (album == null) return;
                  Navigator.pushReplacementNamed(
                    context,
                    AppRoute.album,
                    arguments: AlbumSettingsArguments(album),
                  );
                },
                child: Center(
                  child: Text(
                    state.currentItem?.album ?? "Album Name",
                    style: Theme.of(context).textTheme.labelLarge,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            );
          },
        ),

        IconButton(
          onPressed: () => showSleepSheet(context),
          icon: Icon(Icons.dark_mode_outlined),
        ),
      ],
    );
  }
}
