import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/core/config/app_theme.dart';
import 'package:tunely/core/const/app_route.dart';
import 'package:tunely/core/const/app_router.dart';
import 'package:tunely/core/utils/app_navigator.dart';
import 'package:tunely/features/settings/cubit/customization_cubit.dart';
import 'package:tunely/features/library/cubit/library_cubit.dart';
import 'package:tunely/features/playback/bloc/playback_bloc.dart';
import 'package:tunely/features/playback/mini_player/mini_player_state.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  Set<String> _syncedMissingPaths = const {};

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
  Widget build(BuildContext context) {
    final theme = context.watch<CustomizationCubit>().state;

    return MultiBlocListener(
      listeners: [
        BlocListener<PlaybackBloc, PlaybackState>(
          listenWhen: (prev, curr) =>
              !setEquals(prev.missingPaths, curr.missingPaths),
          listener: (context, state) {
            final library = context.read<LibraryCubit>();
            for (final path in state.missingPaths) {
              if (_syncedMissingPaths.contains(path)) continue;
              library.removeMissingSong(path);
            }
            _syncedMissingPaths = state.missingPaths;
          },
        ),
      ],
      child: DynamicColorBuilder(
        builder: (lightDynamic, darkDynamic) {
          final dynamicAccent = theme.useDynamic ? lightDynamic?.primary : null;

          final accent = dynamicAccent ?? theme.accentColor;

          return MaterialApp(
            navigatorKey: rootNavigatorKey,
            navigatorObservers: [MiniPlayerObserver()],
            onGenerateRoute: AppRouter.onGenerateRoute,
            initialRoute: AppRoute.splash,
            debugShowCheckedModeBanner: false,
            themeMode: theme.themeMode,
            theme: AppTheme.light(accent: accent),
            darkTheme: AppTheme.dark(accent: accent),
            themeAnimationCurve: AppTheme.enter,
            themeAnimationDuration: AppTheme.enterDuration,
            builder: (context, child) {
              // Clamp Text To Match My sizes;
              final mq = MediaQuery.of(context);
              return MediaQuery(
                data: mq.copyWith(
                  textScaler: mq.textScaler.clamp(
                    minScaleFactor: 0.9,
                    maxScaleFactor: 1.15,
                  ),
                ),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}
