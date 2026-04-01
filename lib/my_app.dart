import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/core/common/mini_player_state.dart';
import 'package:tunely/core/config/app_router.dart';
import 'package:tunely/core/config/app_theme.dart';
import 'package:tunely/core/const/app_route.dart';
import 'package:tunely/features/history/history_cubit.dart';
import 'package:tunely/features/lyrics/cubit/lyric_cubit.dart';
import 'package:tunely/features/player/cubit/now_playing_cubit.dart';
import 'package:tunely/features/player/bloc/playback_bloc.dart';
import 'package:tunely/features/theme/theme_cubit.dart';
import 'package:tunely/features/onboarding/on_boarding_view.dart';
import 'package:tunely/features/onboarding/splash_view.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.showOnboarding});
  final bool showOnboarding;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycle) {
    if (lifecycle == AppLifecycleState.inactive) {
      final state = context.read<PlaybackBloc>().state;
      if (state.currentSong == null) return;
      context.read<HistoryCubit>().saveSession(
        currentPath: state.currentSong!.path,
        positionMs: state.pos.inMilliseconds,
        queuePaths: state.queue.map((t) => t.path).toList(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeState = context.watch<ThemeCubit>().state;
    return BlocListener<PlaybackBloc, PlaybackState>(
      listenWhen: (prev, curr) =>
          prev.currentSong?.songId != curr.currentSong?.songId,
      listener: (context, state) {
        context.read<NowPlayingCubit>().extractColors(
          state.currentSong?.songId,
        );
        if (state.currentSong != null) {
          context.read<HistoryCubit>().record(state.currentSong!);
          context.read<LyricCubit>().loadLyrics(state.currentSong!);
        }
      },

      child: MaterialApp(
        navigatorObservers: [MiniPlayerObserver()],
        initialRoute: AppRoute.splash,
        onGenerateRoute: AppRouter.onGenerateRoute,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(accent: themeState.accent),
        darkTheme: AppTheme.dark(accent: themeState.accent),
        themeMode: .system,
        home: widget.showOnboarding
            ? const OnboardingView()
            : const SplashView(),
      ),
    );
  }
}
