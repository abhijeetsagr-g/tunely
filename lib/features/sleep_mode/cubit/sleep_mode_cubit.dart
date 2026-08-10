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
  int _total = 0;

  void start(int seconds) {
    _timer?.cancel();
    _remaining = seconds;
    _total = seconds;

    emit(SleepModeOn(remainingSeconds: _remaining, totalSeconds: _total));

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _remaining--;

      if (_remaining <= 0) {
        _onTimerComplete();
      } else {
        emit(SleepModeOn(remainingSeconds: _remaining, totalSeconds: _total));
      }
    });
  }

  Future<void> startEndOfTrack() async {
    final duration = await _playbackService.durationStream.first;
    final position = await _playbackService.positionStream.first;

    if (duration == null) return;

    final remaining = duration - position;
    final seconds = remaining.inSeconds;
    start(seconds > 0 ? seconds : 1);
  }

  void _onTimerComplete() {
    _playbackService.stop();
    _timer?.cancel();
    _timer = null;
    _total = 0;
    emit(SleepModeOff());
  }

  /// User manually cancels
  void cancel() {
    _timer?.cancel();
    _timer = null;
    _total = 0;
    emit(SleepModeOff());
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
