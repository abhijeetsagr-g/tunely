part of 'lyric_cubit.dart';

abstract class LyricsState {}

class LyricsInitial extends LyricsState {}

class LyricsLoading extends LyricsState {}

class LyricsNotFound extends LyricsState {}

class LyricsInstrumental extends LyricsState {}

class LyricsLoaded extends LyricsState {
  final LyricResult result;
  LyricsLoaded(this.result);
}
