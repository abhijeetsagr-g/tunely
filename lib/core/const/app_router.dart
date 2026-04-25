import 'package:flutter/material.dart';
import 'package:tunely/core/const/app_page_router.dart';
import 'package:tunely/core/const/app_route.dart';
import 'package:tunely/core/utlis/settings_arguments.dart';
import 'package:tunely/features/library/ui/view/album/album_view.dart';
import 'package:tunely/features/library/ui/view/artist/artist_view.dart';
import 'package:tunely/features/library/ui/view/genre/genre_view.dart';
import 'package:tunely/features/lyrics/view/lyrics_view.dart';
import 'package:tunely/features/playback/view/player_view.dart';
import 'package:tunely/features/playback/view/queue/queue_view.dart';
import 'package:tunely/features/root/ui/root_screen.dart';
import 'package:tunely/features/root/ui/view/splash/splash_view.dart';

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
          builder: (_) => const RootScreen(),
        );

      case AppRoute.album:
        final arg = settings.arguments as AlbumSettingsArguments;
        return AppPageRoute(
          settings: settings,
          transition: RouteTransition.fade,
          builder: (_) => AlbumView(album: arg.album),
        );

      case AppRoute.genre:
        final genre = settings.arguments as GenreSettingsArguments;
        return AppPageRoute(
          transition: RouteTransition.fade,
          settings: settings,
          builder: (context) => GenreView(genre: genre.genre),
        );

      case AppRoute.player:
        return AppPageRoute(
          settings: settings,
          transition: RouteTransition.slide,
          builder: (_) => const PlayerView(),
        );

      case AppRoute.artist:
        final artist = settings.arguments as ArtistSettingsArguments;
        return AppPageRoute(
          settings: settings,
          transition: RouteTransition.slide,
          builder: (_) => ArtistView(artist: artist.artist),
        );

      // case AppRoute.playlist:
      //   final playlist = settings.arguments as PlaylistSettingsArguments;
      //   return AppPageRoute(
      //     settings: settings,
      //     builder: (context) => PlaylistView(playlist: playlist.playlist),
      //   );

      case AppRoute.lyrics:
        return AppPageRoute(
          settings: settings,
          transition: RouteTransition.scale,
          builder: (_) => LyricsView(),
        );

      case AppRoute.queue:
        return AppPageRoute(
          settings: settings,
          transition: RouteTransition.fade,
          builder: (context) => QueueView(),
        );

      default:
        return AppPageRoute(
          settings: settings,
          transition: RouteTransition.fade,
          builder: (_) => const RootScreen(),
        );
    }
  }
}
