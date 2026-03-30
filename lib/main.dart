import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/data/repository/history_repository.dart';
import 'package:tunely/data/repository/lyrics_repository.dart';
import 'package:tunely/features/history/history_cubit.dart';
import 'package:tunely/features/library/cubit/library_cubit.dart';
import 'package:tunely/features/lyrics/cubit/lyric_cubit.dart';
import 'package:tunely/service/lyrics_service.dart';
import 'package:tunely/features/player/cubit/now_playing_cubit.dart';
import 'package:tunely/features/player/bloc/playback_bloc.dart';
import 'package:tunely/features/search/cubit/search_cubit.dart';
import 'package:tunely/features/theme/theme_cubit.dart';
import 'package:tunely/data/repository/tune_repository.dart';
import 'package:tunely/service/playback_service.dart';
import 'package:tunely/my_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final repo = TuneRepository();
  final historyRepo = HistoryRepository();
  await historyRepo.init();

  final lyricsRepo = LyricsRepository();
  await lyricsRepo.init();
  final lyricsService = LyricsService(lyricsRepo);

  final audioHandler = await AudioService.init(
    builder: () => PlaybackService(),
    config: const AudioServiceConfig(
      androidNotificationChannelName: "Tunely Playback",
      androidNotificationChannelId: "com.zeenfic.tunely",
      androidNotificationOngoing: true,
    ),
  );

  runApp(
    RepositoryProvider.value(
      value: repo,
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),
          BlocProvider<LibraryCubit>(create: (_) => LibraryCubit(repo)),
          BlocProvider(create: (context) => SearchCubit(repo)),
          BlocProvider(create: (context) => HistoryCubit(historyRepo, repo)),
          BlocProvider<NowPlayingCubit>(
            create: (ctx) => NowPlayingCubit(ctx.read<ThemeCubit>()),
          ),
          BlocProvider<PlaybackBloc>(
            create: (_) => PlaybackBloc(audioHandler, repo),
          ),
          BlocProvider(create: (context) => LyricCubit(lyricsService)),
        ],
        child: MyApp(showOnboarding: false),
      ),
    ),
  );
}
