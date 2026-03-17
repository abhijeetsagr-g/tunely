import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:tunely/core/config/app_route.dart';
import 'package:tunely/core/config/app_theme.dart';
import 'package:tunely/logic/provider/theme/theme_cubit.dart';
import 'package:tunely/ui/album/album_view.dart';
import 'package:tunely/ui/album/generic_view.dart';
import 'package:tunely/ui/filtered_list/filtered_list_view.dart';
import 'package:tunely/ui/player/player_view.dart';
import 'package:tunely/ui/root/mini_player_overlay.dart';
import 'package:tunely/ui/root/root_view.dart';
import 'package:tunely/ui/splash/splash_view.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
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
  }

  @override
  Widget build(BuildContext context) {
    final accent = context.watch<ThemeCubit>().state.accent;
    return MaterialApp(
      navigatorObservers: [routeObserver],
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(accent),
      darkTheme: AppTheme.dark(accent),
      themeMode: context.watch<ThemeCubit>().state.mode,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: _onGenerateRoute,
    );
  }
}
