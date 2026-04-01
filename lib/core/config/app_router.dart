import 'package:flutter/material.dart';
import 'package:tunely/core/config/app_page_route.dart';
import 'package:tunely/core/const/app_route.dart';
import 'package:tunely/features/album/album_view.dart';
import 'package:tunely/features/artist/artist_view.dart';
import 'package:tunely/features/lyrics/view/lyrics_view.dart';
import 'package:tunely/features/onboarding/splash_view.dart';
import 'package:tunely/features/player/view/player_view.dart';
import 'package:tunely/features/shell/root_view.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoute.splash:
        return AppPageRoute(
          settings: settings,
          transition: RouteTransition.fade,
          builder: (_) => const SplashView(),
        );

      case AppRoute.root:
        return AppPageRoute(
          settings: settings,
          transition: RouteTransition.fade,
          builder: (_) => const RootView(),
        );

      case AppRoute.album:
        final albumId = settings.arguments as int;
        return AppPageRoute(
          settings: settings,
          transition: RouteTransition.fade,
          builder: (_) => AlbumView(albumId: albumId),
        );

      case AppRoute.player:
        return AppPageRoute(
          settings: settings,
          transition: RouteTransition.scale,
          builder: (_) => const PlayerView(),
        );

      case AppRoute.artist:
        final artist = settings.arguments as String;
        return AppPageRoute(
          settings: settings,
          transition: RouteTransition.slide,
          builder: (_) => ArtistView(artistName: artist),
        );

      case AppRoute.lyrics:
        return AppPageRoute(
          settings: settings,
          transition: RouteTransition.fade,
          builder: (_) => LyricsView(),
        );

      default:
        return AppPageRoute(
          settings: settings,
          transition: RouteTransition.fade,
          builder: (_) => const RootView(),
        );
    }
  }
}
