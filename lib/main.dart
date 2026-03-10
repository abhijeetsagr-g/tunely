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
import 'package:tunely/ui/album/generic_view.dart';
import 'package:tunely/ui/filtered_list/filtered_list_view.dart';
import 'package:tunely/ui/player/player_view.dart';
import 'package:tunely/ui/root/mini_player_overlay.dart';
import 'package:tunely/ui/root/root_view.dart';
import 'package:tunely/ui/splash/splash_view.dart';

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
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),
        BlocProvider<QueryCubit>(create: (_) => QueryCubit()),
        BlocProvider<PlaybackBloc>(create: (_) => PlaybackBloc(audioHandler)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  OverlayEntry? _miniPlayerEntry;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _insertMiniPlayer());
  }

  void _insertMiniPlayer() {
    final overlay = _navigatorKey.currentState?.overlay;
    if (overlay == null) return;

    _miniPlayerEntry = OverlayEntry(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<PlaybackBloc>()),
          BlocProvider.value(value: context.read<ThemeCubit>()),
        ],
        child: const MiniPlayerOverlay(),
      ),
    );

    overlay.insert(_miniPlayerEntry!);
  }

  @override
  void dispose() {
    _miniPlayerEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = context.watch<ThemeCubit>().state.accent;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: _navigatorKey,
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
              builder: (_) => FilteredListView(type: args.type),
            );
          case AppRoutes.generic:
            final args = settings.arguments as GenericViewArgs;
            return MaterialPageRoute(builder: (_) => GenericView(args: args));
          default:
            return MaterialPageRoute(builder: (_) => const RootView());
        }
      },
    );
  }
}
