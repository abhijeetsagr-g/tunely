import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/logic/provider/playback/playback_bloc.dart';
import 'package:tunely/logic/provider/query/query_cubit.dart';
import 'package:tunely/logic/provider/theme/theme_cubit.dart';
import 'package:tunely/logic/repository/tune_repository.dart';
import 'package:tunely/logic/service/playback_service.dart';
import 'package:tunely/my_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final audioHandler = await AudioService.init(
    builder: () => PlaybackService(),
    config: const AudioServiceConfig(
      androidNotificationChannelName: "Tunely Playback",
      androidNotificationChannelId: "com.zeenfic.tunely",
      androidNotificationOngoing: true,
    ),
  );

  final repo = TuneRepository();

  runApp(
    RepositoryProvider.value(
      value: repo,
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),
          BlocProvider<QueryCubit>(create: (_) => QueryCubit(repo)),
          BlocProvider<PlaybackBloc>(
            create: (_) => PlaybackBloc(audioHandler, repo),
          ),
        ],
        child: MyApp(),
      ),
    ),
  );
}
