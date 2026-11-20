import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/core/const/app_route.dart';
import 'package:tunely/features/playback/bloc/playback_bloc.dart';
import 'package:tunely/features/playback/widget/control_button.dart';
import 'package:tunely/features/playback/widget/next_song_label.dart';
import 'package:tunely/features/playback/widget/player_album_art.dart';
import 'package:tunely/features/playback/widget/player_app_bar.dart';
import 'package:tunely/features/playback/widget/player_gradient_background.dart';
import 'package:tunely/features/playback/widget/seek_bar.dart';
import 'package:tunely/features/playback/widget/song_info.dart';

class PlayerView extends StatelessWidget {
  const PlayerView({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<PlaybackBloc>();
    final size = MediaQuery.sizeOf(context);
    final isWide = size.width > 600 && size.height > 600;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: const PlayerGradientBackground()),
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
                      PlayerAppBar(),
                      Expanded(
                        child: GestureDetector(
                          onHorizontalDragEnd: (details) {
                            if (details.primaryVelocity == null) return;

                            if (details.primaryVelocity! > 0) {
                              bloc.add(SkipToPreviousEvent());
                            } else if (details.primaryVelocity! < 0) {
                              bloc.add(SkipToNextEvent());
                            }
                          },

                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: PlayerAlbumArt(),
                          ),
                        ),
                      ),

                      SizedBox(height: size.height * 0.025),
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
                      SizedBox(height: size.height * 0.05),
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
