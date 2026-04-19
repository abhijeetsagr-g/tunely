part of 'lyrics_cubit.dart';

sealed class LyricsState {
  const LyricsState();
}

class LyricsIdle extends LyricsState {
  const LyricsIdle();
}

class LyricsLoading extends LyricsState {
  const LyricsLoading();
}

class LyricsNotFound extends LyricsState {
  const LyricsNotFound();
}

class LyricsLoaded extends LyricsState {
  final LyricsResult result;
  final Tune tune;
  final int temporaryOffset;

  const LyricsLoaded({
    required this.result,
    required this.tune,
    this.temporaryOffset = 0,
  });

  // Effective offset = persisted + temporary adjustment
  int get effectiveOffset => result.offsetMs + temporaryOffset;

  LyricsLoaded copyWith({
    LyricsResult? result,
    Tune? tune,
    int? temporaryOffset,
  }) => LyricsLoaded(
    result: result ?? this.result,
    tune: tune ?? this.tune,
    temporaryOffset: temporaryOffset ?? this.temporaryOffset,
  );
}
