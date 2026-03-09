import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/core/config/app_route.dart';
import 'package:tunely/core/config/app_theme.dart';
import 'package:tunely/logic/provider/playback/playback_bloc.dart';
import 'package:tunely/logic/provider/query/query_cubit.dart';
import 'package:tunely/logic/service/playback_service.dart';
import 'package:tunely/ui/home/home_view.dart';
import 'package:tunely/ui/player/player_view.dart';
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (_) => const SplashView(),
        AppRoutes.home: (_) => const HomeView(),
        AppRoutes.player: (_) => const PlayerView(),
      },
    );
  }
}
