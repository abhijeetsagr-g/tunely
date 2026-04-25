import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/features/playback/service/playback_service.dart';

part 'sleep_mode_state.dart';

class SleepModeCubit extends Cubit<SleepModeState> {
  final PlaybackService _playbackService;

  SleepModeCubit({required PlaybackService playbackService})
    : _playbackService = playbackService,
      super(SleepModeOff());

  Timer? _timer;
  int _remaining = 0;

  void start(int seconds) {
    _timer?.cancel();
    _remaining = seconds;

    emit(SleepModeOn(_remaining));

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _remaining--;

      if (_remaining <= 0) {
        _onTimerComplete();
      } else {
        emit(SleepModeOn(_remaining));
      }
    });
  }

  void _onTimerComplete() {
    _playbackService.stop();
    _timer?.cancel();
    _timer = null;
    emit(SleepModeOff());
  }

  /// User manually cancels
  void cancel() {
    _timer?.cancel();
    _timer = null;
    emit(SleepModeOff());
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
