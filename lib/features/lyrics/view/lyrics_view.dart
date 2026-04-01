import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/features/lyrics/view/widget/lyrics_option_sheet.dart';
import 'package:tunely/features/lyrics/view/widget/lyrics_header.dart';
import 'package:tunely/features/lyrics/view/widget/lyrics_body.dart';
import 'package:tunely/features/player/bloc/playback_bloc.dart';
import 'package:tunely/features/player/view/widget/control_buttons.dart';
import 'package:tunely/features/player/view/widget/seek_bar.dart';

class LyricsView extends StatefulWidget {
  const LyricsView({super.key});

  @override
  State<LyricsView> createState() => _LyricsViewState();
}

class _LyricsViewState extends State<LyricsView> {
  bool _isSynced = true;

  @override
  Widget build(BuildContext context) {
    final tune = context.select((PlaybackBloc bloc) => bloc.state.currentSong);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            LyricsHeader(
              isSynced: _isSynced,
              onSyncedChanged: (val) => setState(() => _isSynced = val),
              onMoreTap: () => LyricsOptionsSheet.show(context, tune),
            ),
            Expanded(child: LyricsBody(isSynced: _isSynced)),
            const SeekBar(),
            const ControlButtons(),
          ],
        ),
      ),
    );
  }
}
