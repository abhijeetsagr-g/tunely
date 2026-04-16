part of 'stats_cubit.dart';

sealed class StatsState {}

class StatsInitial extends StatsState {}

class StatsLoaded extends StatsState {
  final List<Tune> mostPlayed;
  final List<Tune> recent;
  final List<Tune> liked;

  StatsLoaded({
    required this.mostPlayed,
    required this.recent,
    required this.liked,
  });
}
