import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/core/extensions/title_case.dart';
import 'package:tunely/features/lyrics/view/widget/sync_lyrics_widget.dart';
import 'package:tunely/features/playback/bloc/playback_bloc.dart';
import 'package:tunely/features/playback/view/widget/control_button.dart';
import 'package:tunely/features/playback/view/widget/player_gradient_background.dart';
import 'package:tunely/features/playback/view/widget/seek_bar.dart';

class LyricsView extends StatelessWidget {
  const LyricsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const PlayerGradientBackground(),

          SafeArea(
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.keyboard_arrow_left),
                    ),
                    Center(
                      child: Text(
                        context
                                .watch<PlaybackBloc>()
                                .state
                                .currentItem
                                ?.title
                                .toTitleCase() ??
                            "Unknown Song",
                      ),
                    ),
                    Spacer(),
                    Icon(Icons.more_vert),
                  ],
                ),
                Expanded(child: SyncLyricsWidget()),
                SeekBar(),
                ControlButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
