import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/core/config/app_route.dart';
import 'package:tunely/core/config/app_theme.dart';
import 'package:tunely/logic/provider/playback/playback_bloc.dart';
import 'package:tunely/logic/provider/query/query_cubit.dart';
import 'package:tunely/logic/provider/theme/theme_cubit.dart';
import 'package:tunely/logic/service/playback_service.dart';
import 'package:tunely/ui/album/album_view.dart';
import 'package:tunely/ui/filtered_list/filtered_list_view.dart';

import 'package:tunely/ui/player/player_view.dart';
import 'package:tunely/ui/root/root_view.dart';
import 'package:tunely/ui/splash/splash_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final audioHandler = await AudioService.init(
    builder: () => PlaybackService(),
    config: AudioServiceConfig(
      androidNotificationChannelName: "Tunely Playback",
      androidNotificationChannelId: "com.zeenfic.tunely",
      androidNotificationOngoing: true,
    ),
  );
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(create: (context) => ThemeCubit()),
        BlocProvider(create: (context) => QueryCubit()),
        BlocProvider(
          create: (BuildContext context) => PlaybackBloc(audioHandler),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final accent = context.watch<ThemeCubit>().state.accent;

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: AppTheme.light(accent),
      darkTheme: AppTheme.dark(accent),
      themeMode: context.watch<ThemeCubit>().state.mode,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppRoutes.splash:
            return MaterialPageRoute(builder: (_) => const SplashView());
          case AppRoutes.home:
            return MaterialPageRoute(builder: (_) => const RootView());
          case AppRoutes.player:
            return MaterialPageRoute(builder: (_) => const PlayerView());
          case AppRoutes.album:
            final args = settings.arguments as AlbumViewArgs;
            return MaterialPageRoute(
              builder: (_) => AlbumView(album: args.album, tunes: args.tunes),
            );
          case AppRoutes.filtered:
            final args = settings.arguments as FilteredListArgs;
            return MaterialPageRoute(
              builder: (context) => FilteredListView(type: args.type),
            );
          default:
            return MaterialPageRoute(builder: (_) => const RootView());
        }
      },
    );
  }
}
