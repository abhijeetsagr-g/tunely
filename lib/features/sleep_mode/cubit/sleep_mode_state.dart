part of 'sleep_mode_cubit.dart';

abstract class SleepModeState {}

class SleepModeOff extends SleepModeState {}

class SleepModeOn extends SleepModeState {
  final int remainingSeconds;

  SleepModeOn(this.remainingSeconds);
}
