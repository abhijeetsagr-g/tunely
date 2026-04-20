import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/features/lyrics/cubit/lyrics_cubit.dart';
import 'package:tunely/features/lyrics/model/lyrics_result.dart';
import 'package:tunely/features/lyrics/view/widget/lyrics_empty_state.dart';
import 'package:tunely/features/lyrics/view/widget/synced_lyrics_list.dart';

class SyncLyricsWidget extends StatelessWidget {
  const SyncLyricsWidget({super.key});

  LyricsResult _effectiveResult(LyricsLoaded s) => s.temporaryOffset == 0
      ? s.result
      : s.result.copyWith(offsetMs: s.result.offsetMs + s.temporaryOffset);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LyricsCubit, LyricsState>(
      builder: (context, state) => switch (state) {
        LyricsLoading() => const LyricsLoadingState(),
        LyricsNotFound() => const LyricsNotFoundState(),
        LyricsIdle() => const SizedBox.shrink(),
        LyricsLoaded() => _buildLoaded(state),
      },
    );
  }

  Widget _buildLoaded(LyricsLoaded state) {
    final result = _effectiveResult(state);
    if (result.instrumental) return const LyricsInstrumentalState();
    if (result.synced.isEmpty && result.plain != null) {
      return LyricsPlainView(plain: result.plain!);
    }
    return SyncedLyricsList(result: result);
  }
}
