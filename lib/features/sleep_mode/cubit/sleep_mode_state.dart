part of 'sleep_mode_cubit.dart';

sealed class SleepModeState {
  const SleepModeState();
}

class SleepModeOff extends SleepModeState {
  const SleepModeOff();
}

class SleepModeOn extends SleepModeState {
  const SleepModeOn({
    required this.remainingSeconds,
    required this.totalSeconds,
  });

  final int remainingSeconds;
  final int totalSeconds;
}
