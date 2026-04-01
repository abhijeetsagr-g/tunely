import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/features/lyrics/cubit/lyric_cubit.dart';
import 'package:tunely/features/lyrics/view/widget/sync_lyric_widget.dart';
import 'package:tunely/features/lyrics/view/widget/unsync_lyric_widget.dart';

class LyricsBody extends StatelessWidget {
  final bool isSynced;

  const LyricsBody({super.key, required this.isSynced});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LyricCubit, LyricsState>(
      builder: (context, state) {
        if (state is LyricsLoaded) {
          return isSynced
              ? SyncLyricWidget(lyrics: state.result.synced)
              : UnsyncedLyricWidget(result: state.result);
        }
        if (state is LyricsInitial || state is LyricsLoading) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }
        if (state is LyricsInstrumental) {
          return const Center(child: Text("..."));
        }
        return const Center(child: Text("No Lyrics Found"));
      },
    );
  }
}
