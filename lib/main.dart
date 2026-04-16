import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:path_provider/path_provider.dart';

import 'package:tunely/data/repository/lyrics_repository.dart';
import 'package:tunely/data/repository/tune_repository.dart';

import 'package:tunely/features/library/cubit/library_cubit.dart';
import 'package:tunely/features/lyrics/cubit/lyric_cubit.dart';
import 'package:tunely/features/player/bloc/playback_bloc.dart';
import 'package:tunely/features/player/cubit/now_playing_cubit.dart';
import 'package:tunely/features/search/cubit/search_cubit.dart';
import 'package:tunely/features/session/cubit/session_cubit.dart';
import 'package:tunely/features/session/repository/session_repository.dart';
import 'package:tunely/features/stats/cubit/stats_cubit.dart';
import 'package:tunely/features/stats/repository/stats_repository.dart';
import 'package:tunely/features/stats/service/stats_service.dart';
import 'package:tunely/features/theme/theme_cubit.dart';

import 'package:tunely/service/audio_query_service.dart';
import 'package:tunely/service/lyrics_service.dart';

import 'package:tunely/features/playback/service/playback_service.dart';
import 'package:tunely/hive_registrar.g.dart';
import 'package:tunely/my_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 Hive init
  final dir = await getApplicationDocumentsDirectory();
  Hive.init(dir.path);

  Hive.registerAdapters();

  final statsRepo = StatsRepository();
  await statsRepo.init();

  // 🔥 Audio Service
  final audioHandler = await AudioService.init(
    builder: () => PlaybackService(),
    config: const AudioServiceConfig(
      androidNotificationChannelName: "Tunely Playback",
      androidNotificationChannelId: "com.abhijeetsagr.tunely",
      androidNotificationOngoing: true,
    ),
  );

  // 🔥 Core repos/services
  final tuneRepo = TuneRepository();
  final lyricsRepo = LyricsRepository();
  final sessionRepo = SessionRepository();

  final audioQueryService = AudioQueryService();
  final lyricsService = LyricsService(lyricsRepo);

  // 🔥 Theme
  final themeCubit = ThemeCubit();
  await themeCubit.load();

  // 🔥 Stats (IMPORTANT: keep reference alive)
  final statsService = StatsService(audioHandler.onTrackChanged, statsRepo);

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: tuneRepo),
        RepositoryProvider.value(value: statsRepo),
        RepositoryProvider.value(value: statsService),
        RepositoryProvider.value(value: sessionRepo),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: themeCubit),

          BlocProvider(
            create: (_) => LibraryCubit(tuneRepo, audioQueryService),
          ),

          BlocProvider(create: (_) => SearchCubit(tuneRepo)),

          BlocProvider(
            create: (ctx) =>
                NowPlayingCubit(ctx.read<ThemeCubit>(), audioQueryService),
          ),

          BlocProvider(create: (_) => PlaybackBloc(audioHandler, tuneRepo)),

          BlocProvider(create: (_) => LyricCubit(lyricsService)),

          BlocProvider(create: (_) => SessionCubit(sessionRepo)),

          BlocProvider(create: (_) => StatsCubit(statsRepo)),
        ],
        child: MyApp(showOnboarding: !themeCubit.seenOnboarding),
      ),
    ),
  );
}
