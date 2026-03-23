import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/logic/provider/library/library_cubit.dart';
import 'package:tunely/logic/provider/now_playing/now_playing_cubit.dart';
import 'package:tunely/logic/provider/playback/playback_bloc.dart';
import 'package:tunely/logic/provider/search/search_cubit.dart';
import 'package:tunely/logic/provider/theme/theme_cubit.dart';
import 'package:tunely/data/repository/tune_repository.dart';
import 'package:tunely/logic/service/playback_service.dart';
import 'package:tunely/my_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final repo = TuneRepository();
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
          BlocProvider<NowPlayingCubit>(
            create: (ctx) => NowPlayingCubit(ctx.read<ThemeCubit>()),
          ),
          BlocProvider<PlaybackBloc>(
            create: (_) => PlaybackBloc(audioHandler, repo),
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );
}
