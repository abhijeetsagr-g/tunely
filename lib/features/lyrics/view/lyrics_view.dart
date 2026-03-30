import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/features/lyrics/cubit/lyric_cubit.dart';
import 'package:tunely/features/lyrics/view/widget/lyrics_search_sheet.dart';
import 'package:tunely/features/lyrics/view/widget/sync_lyric_widget.dart';
import 'package:tunely/features/player/bloc/playback_bloc.dart';
import 'package:tunely/features/player/view/widget/control_buttons.dart';
import 'package:tunely/features/player/view/widget/seek_bar.dart';
import 'package:tunely/shared/widgets/circle_button.dart';

class LyricsView extends StatelessWidget {
  const LyricsView({super.key});

  @override
  Widget build(BuildContext context) {
    final tune = context.select((PlaybackBloc bloc) => bloc.state.currentSong);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  BlocBuilder<LyricCubit, LyricsState>(
                    builder: (context, state) {
                      if (state is LyricsLoaded) {
                        return SyncLyricWidget(lyrics: state.result.synced);
                      }

                      if (state is LyricsInitial || state is LyricsLoading) {
                        return const Center(
                          child: CircularProgressIndicator.adaptive(),
                        );
                      }

                      if (state is LyricsInstrumental) {
                        return const Center(child: Text("Instrumental"));
                      }

                      return const Center(child: Text("No Lyrics Found"));
                    },
                  ),

                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Row(
                      children: [
                        CircleButton(
                          icon: Icons.replay,
                          onTap: () {
                            if (tune != null) {
                              context.read<LyricCubit>().reloadLyrics(tune);
                            }
                          },
                        ),
                        CircleButton(
                          icon: Icons.search,
                          onTap: () {
                            if (tune != null) {
                              LyricsSearchSheet.show(context, tune);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SeekBar(),
            const ControlButtons(),
          ],
        ),
      ),
    );
  }
}
