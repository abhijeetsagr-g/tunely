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
    final size = MediaQuery.sizeOf(context);
    final isWide = size.width > 600;

    return Scaffold(
      body: Stack(
        children: [
          const PlayerGradientBackground(),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isWide ? 500 : double.infinity,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isWide ? 32.0 : 20.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _PlayerAppBar(),
                      Expanded(
                        child: Align(
                          alignment: Alignment.center,
                          child: PlayerAlbumArt(),
                        ),
                      ),
                      SongInfo(),
                      SizedBox(height: size.height * 0.025),
                      SeekBar(),
                      SizedBox(height: size.height * 0.025),
                      ControlButtons(),
                      SizedBox(height: size.height * 0.06),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.pushNamed(context, AppRoute.queue);
                            },
                            icon: const Icon(Icons.queue_music_outlined),
                          ),
                          Expanded(child: NextSongLabel()),
                          IconButton(
                            onPressed: () =>
                                Navigator.pushNamed(context, AppRoute.lyrics),
                            icon: const Icon(Icons.lyrics_outlined),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
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
                  final cubitState = context.read<LibraryCubit>().state;
                  if (cubitState is! LibraryLoaded) return;
                  final album = cubitState.albums.firstWhereOrNull(
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
