part of 'history_cubit.dart';

class HistoryState {
  final List<Tune> recentTunes;
  final List<Tune> topTunes;

  const HistoryState({this.recentTunes = const [], this.topTunes = const []});
}
