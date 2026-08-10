import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/core/config/app_theme.dart';
import 'package:tunely/core/const/app_route.dart';
import 'package:tunely/core/const/app_router.dart';
import 'package:tunely/features/customization/cubit/customization_cubit.dart';
import 'package:tunely/features/library/cubit/library_cubit.dart';
import 'package:tunely/features/playback/bloc/playback_bloc.dart';
import 'package:tunely/features/playback/view/mini_player/mini_player_state.dart';

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
        // Sync songs that failed to load with the library so they disappear
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

      child: MaterialApp(
        navigatorObservers: [MiniPlayerObserver()],
        onGenerateRoute: AppRouter.onGenerateRoute,
        initialRoute: AppRoute.splash,
        debugShowCheckedModeBanner: false,
        themeMode: theme.themeMode,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
      ),
    );
  }
}
