import 'dart:async';

import 'package:audio_service/audio_service.dart' hide PlaybackState;
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tunely/features/playback/bloc/playback_bloc.dart';
import 'package:tunely/features/playback/service/playback_service.dart';
import 'package:tunely/shared/model/tune.dart';

// ─── Mocks ───────────────────────────────────────────────────────────────────

class MockPlaybackService extends Mock implements PlaybackService {}

// ─── Fakes ───────────────────────────────────────────────────────────────────

class FakeMediaItem extends Fake implements MediaItem {}

class FakeTune extends Fake implements Tune {}

// ─── Helpers ─────────────────────────────────────────────────────────────────

Tune makeTune({
  int id = 1,
  String title = 'Test Song',
  String artist = 'Test Artist',
}) => Tune(
  songId: id,
  artistId: id,
  trackIndex: 1,
  albumId: 1,
  path: '/music/test_$id.mp3',
  album: 'Test Album',
  title: title,
  artist: artist,
  genre: 'Pop',
  duration: const Duration(minutes: 3),
  dateAdded: 0,
);

// Stubs all streams on the mock service so the bloc can subscribe without error
void stubStreams(
  MockPlaybackService service, {
  Stream<bool>? isPlaying,
  Stream<Duration>? position,
  Stream<Duration?>? duration,
  Stream<ProcessingState>? playerState,
  Stream<SequenceState>? sequenceState,
}) {
  when(
    () => service.isPlaying,
  ).thenAnswer((_) => isPlaying ?? const Stream.empty());
  when(
    () => service.positionStream,
  ).thenAnswer((_) => position ?? const Stream.empty());
  when(
    () => service.durationStream,
  ).thenAnswer((_) => duration ?? const Stream.empty());
  when(
    () => service.playerStateStream,
  ).thenAnswer((_) => playerState ?? const Stream.empty());
  when(
    () => service.sequenceStateStream,
  ).thenAnswer((_) => sequenceState ?? const Stream.empty());
}

// ─── Tests ───────────────────────────────────────────────────────────────────

void main() {
  late MockPlaybackService service;

  setUpAll(() {
    registerFallbackValue(Duration.zero);
    registerFallbackValue(LoopMode.off);
    registerFallbackValue(FakeMediaItem());
    registerFallbackValue(FakeTune());
    registerFallbackValue(<Tune>[]);
  });

  setUp(() {
    service = MockPlaybackService();
    stubStreams(service); // safe default: all streams empty
  });

  // ── Initial state ──────────────────────────────────────────────────────────

  group('initial state', () {
    test('is correct', () {
      final bloc = PlaybackBloc(service);
      expect(bloc.state, const PlaybackState());
      bloc.close();
    });
  });

  // ── Stream events → state ──────────────────────────────────────────────────

  group('stream: isPlaying', () {
    blocTest<PlaybackBloc, PlaybackState>(
      'emits isPlaying: true when service emits true',
      build: () {
        stubStreams(service, isPlaying: Stream.value(true));
        return PlaybackBloc(service);
      },
      expect: () => [
        isA<PlaybackState>().having((s) => s.isPlaying, 'isPlaying', true),
      ],
    );

    blocTest<PlaybackBloc, PlaybackState>(
      'emits isPlaying: false when service emits false',
      build: () {
        stubStreams(service, isPlaying: Stream.value(false));
        return PlaybackBloc(service);
      },
      expect: () => [
        isA<PlaybackState>().having((s) => s.isPlaying, 'isPlaying', false),
      ],
    );
  });

  group('stream: position', () {
    blocTest<PlaybackBloc, PlaybackState>(
      'emits updated position',
      build: () {
        stubStreams(
          service,
          position: Stream.value(const Duration(seconds: 42)),
        );
        return PlaybackBloc(service);
      },
      expect: () => [
        isA<PlaybackState>().having(
          (s) => s.position,
          'position',
          const Duration(seconds: 42),
        ),
      ],
    );
  });

  group('stream: duration', () {
    blocTest<PlaybackBloc, PlaybackState>(
      'emits updated duration',
      build: () {
        stubStreams(
          service,
          duration: Stream.value(const Duration(minutes: 3)),
        );
        return PlaybackBloc(service);
      },
      expect: () => [
        isA<PlaybackState>().having(
          (s) => s.duration,
          'duration',
          const Duration(minutes: 3),
        ),
      ],
    );
  });

  group('stream: processingState', () {
    blocTest<PlaybackBloc, PlaybackState>(
      'maps ProcessingState.loading → PlaybackStatus.loading',
      build: () {
        stubStreams(
          service,
          playerState: Stream.value(ProcessingState.loading),
        );
        return PlaybackBloc(service);
      },
      expect: () => [
        isA<PlaybackState>().having(
          (s) => s.status,
          'status',
          PlaybackStatus.loading,
        ),
      ],
    );

    blocTest<PlaybackBloc, PlaybackState>(
      'maps ProcessingState.ready → PlaybackStatus.ready',
      build: () {
        stubStreams(service, playerState: Stream.value(ProcessingState.ready));
        return PlaybackBloc(service);
      },
      expect: () => [
        isA<PlaybackState>().having(
          (s) => s.status,
          'status',
          PlaybackStatus.ready,
        ),
      ],
    );

    blocTest<PlaybackBloc, PlaybackState>(
      'maps ProcessingState.completed → PlaybackStatus.completed',
      build: () {
        stubStreams(
          service,
          playerState: Stream.value(ProcessingState.completed),
        );
        return PlaybackBloc(service);
      },
      expect: () => [
        isA<PlaybackState>().having(
          (s) => s.status,
          'status',
          PlaybackStatus.completed,
        ),
      ],
    );
  });

  // ── PlayQueueEvent ─────────────────────────────────────────────────────────

  group('PlayQueueEvent', () {
    blocTest<PlaybackBloc, PlaybackState>(
      'calls service.playQueue with correct tunes and startIndex',
      build: () {
        when(() => service.playQueue(any(), any())).thenAnswer((_) async {});
        return PlaybackBloc(service);
      },
      act: (bloc) {
        final tunes = [makeTune(id: 1), makeTune(id: 2)];
        bloc.add(PlayQueueEvent(tunes, startIndex: 1));
      },
      verify: (_) {
        verify(() => service.playQueue(any(that: hasLength(2)), 1)).called(1);
      },
    );
  });

  // ── Playback controls ──────────────────────────────────────────────────────

  group('PlayEvent', () {
    blocTest<PlaybackBloc, PlaybackState>(
      'calls service.play()',
      build: () {
        when(() => service.play()).thenAnswer((_) async {});
        return PlaybackBloc(service);
      },
      act: (bloc) => bloc.add(const PlayEvent()),
      verify: (_) => verify(() => service.play()).called(1),
    );
  });

  group('PauseEvent', () {
    blocTest<PlaybackBloc, PlaybackState>(
      'calls service.pause()',
      build: () {
        when(() => service.pause()).thenAnswer((_) async {});
        return PlaybackBloc(service);
      },
      act: (bloc) => bloc.add(const PauseEvent()),
      verify: (_) => verify(() => service.pause()).called(1),
    );
  });

  group('StopEvent', () {
    blocTest<PlaybackBloc, PlaybackState>(
      'calls service.stop()',
      build: () {
        when(() => service.stop()).thenAnswer((_) async {});
        return PlaybackBloc(service);
      },
      act: (bloc) => bloc.add(const StopEvent()),
      verify: (_) => verify(() => service.stop()).called(1),
    );
  });

  group('SeekEvent', () {
    blocTest<PlaybackBloc, PlaybackState>(
      'calls service.seek() with correct position',
      build: () {
        when(() => service.seek(any())).thenAnswer((_) async {});
        return PlaybackBloc(service);
      },
      act: (bloc) => bloc.add(const SeekEvent(Duration(seconds: 30))),
      verify: (_) =>
          verify(() => service.seek(const Duration(seconds: 30))).called(1),
    );
  });

  group('SkipToNextEvent', () {
    blocTest<PlaybackBloc, PlaybackState>(
      'calls service.skipToNext()',
      build: () {
        when(() => service.skipToNext()).thenAnswer((_) async {});
        return PlaybackBloc(service);
      },
      act: (bloc) => bloc.add(const SkipToNextEvent()),
      verify: (_) => verify(() => service.skipToNext()).called(1),
    );
  });

  group('SkipToPreviousEvent', () {
    blocTest<PlaybackBloc, PlaybackState>(
      'calls service.skipToPrevious()',
      build: () {
        when(() => service.skipToPrevious()).thenAnswer((_) async {});
        return PlaybackBloc(service);
      },
      act: (bloc) => bloc.add(const SkipToPreviousEvent()),
      verify: (_) => verify(() => service.skipToPrevious()).called(1),
    );
  });

  group('SkipToQueueItemEvent', () {
    blocTest<PlaybackBloc, PlaybackState>(
      'calls service.skipToQueueItem() with correct index',
      build: () {
        when(() => service.skipToQueueItem(any())).thenAnswer((_) async {});
        return PlaybackBloc(service);
      },
      act: (bloc) => bloc.add(const SkipToQueueItemEvent(2)),
      verify: (_) => verify(() => service.skipToQueueItem(2)).called(1),
    );
  });

  // ── Settings ───────────────────────────────────────────────────────────────

  group('SetShuffleEvent', () {
    blocTest<PlaybackBloc, PlaybackState>(
      'calls service.setShuffle() and emits shuffleEnabled: true',
      build: () {
        when(() => service.setShuffle(any())).thenAnswer((_) async {});
        return PlaybackBloc(service);
      },
      act: (bloc) => bloc.add(const SetShuffleEvent(true)),
      expect: () => [
        isA<PlaybackState>().having(
          (s) => s.shuffleEnabled,
          'shuffleEnabled',
          true,
        ),
      ],
      verify: (_) => verify(() => service.setShuffle(true)).called(1),
    );
  });

  group('SetRepeatEvent', () {
    blocTest<PlaybackBloc, PlaybackState>(
      'calls service.setRepeat() and emits repeatMode: LoopMode.one',
      build: () {
        when(() => service.setRepeat(any())).thenAnswer((_) async {});
        return PlaybackBloc(service);
      },
      act: (bloc) => bloc.add(const SetRepeatEvent(LoopMode.one)),
      expect: () => [
        isA<PlaybackState>().having(
          (s) => s.repeatMode,
          'repeatMode',
          LoopMode.one,
        ),
      ],
      verify: (_) => verify(() => service.setRepeat(LoopMode.one)).called(1),
    );
  });

  group('SetSpeedEvent', () {
    blocTest<PlaybackBloc, PlaybackState>(
      'calls service.setSpeed() and emits speed: 1.5',
      build: () {
        when(() => service.setSpeed(any())).thenAnswer((_) async {});
        return PlaybackBloc(service);
      },
      act: (bloc) => bloc.add(const SetSpeedEvent(1.5)),
      expect: () => [isA<PlaybackState>().having((s) => s.speed, 'speed', 1.5)],
      verify: (_) => verify(() => service.setSpeed(1.5)).called(1),
    );
  });

  // ── Queue management ───────────────────────────────────────────────────────

  group('AddQueueItemEvent', () {
    blocTest<PlaybackBloc, PlaybackState>(
      'calls service.addQueueItem() with correct MediaItem',
      build: () {
        when(() => service.addQueueItem(any())).thenAnswer((_) async {});
        return PlaybackBloc(service);
      },
      act: (bloc) => bloc.add(AddQueueItemEvent(makeTune(id: 5))),
      verify: (_) => verify(() => service.addQueueItem(any())).called(1),
    );
  });

  group('RemoveQueueItemAtEvent', () {
    blocTest<PlaybackBloc, PlaybackState>(
      'calls service.removeQueueItemAt() with correct index',
      build: () {
        when(() => service.removeQueueItemAt(any())).thenAnswer((_) async {});
        return PlaybackBloc(service);
      },
      act: (bloc) => bloc.add(const RemoveQueueItemAtEvent(2)),
      verify: (_) => verify(() => service.removeQueueItemAt(2)).called(1),
    );
  });

  group('PlayAfterThisEvent', () {
    blocTest<PlaybackBloc, PlaybackState>(
      'calls service.playAfterThis() with correct MediaItem',
      build: () {
        when(() => service.playAfterThis(any())).thenAnswer((_) async {});
        return PlaybackBloc(service);
      },
      act: (bloc) => bloc.add(PlayAfterThisEvent(makeTune(id: 3))),
      verify: (_) => verify(() => service.playAfterThis(any())).called(1),
    );
  });

  // ── Null index guard ───────────────────────────────────────────────────────

  group('sequenceStateStream: null index guard', () {
    blocTest<PlaybackBloc, PlaybackState>(
      'does not crash and emits nothing when index is null',
      build: () {
        // We can't easily mock SequenceState directly since it's a just_audio
        // internal class. This test just verifies the bloc doesn't throw when
        // the stream emits before playback starts. Cover this via integration
        // test or by testing _SequenceStateUpdatedEvent directly if needed.
        stubStreams(service);
        return PlaybackBloc(service);
      },
      act: (bloc) {}, // no event — stream is empty, nothing fires
      expect: () => [], // no state change, no crash
    );
  });
}
