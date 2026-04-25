import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/core/const/app_route.dart';
import 'package:tunely/features/library/cubit/library_cubit.dart';
import 'package:tunely/features/library/model/library_scan_result.dart';
import 'package:tunely/features/playback/bloc/playback_bloc.dart';
import 'package:tunely/features/playlist/cubit/playlist_cubit.dart';
import 'package:tunely/features/search/cubit/search_cubit.dart';
import 'package:tunely/features/session/cubit/session_cubit.dart';
import 'package:tunely/features/stats/cubit/stats_cubit.dart';
import 'package:tunely/shared/model/tune.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    // initialize library
    final library = context.read<LibraryCubit>();
    await library.initialLoad();
    if (!mounted) return;

    // Load stats
    if (library.state is LibraryLoaded) {
      final state = library.state as LibraryLoaded;

      context.read<StatsCubit>().load(state.tunes);

      context.read<SearchCubit>().setLibrary(
        LibraryScanResult(
          tunes: state.tunes,
          artists: state.artists,
          albums: state.albums,
          genres: state.genres,
          playlists: state.playlists,
        ),
      );
    }

    // Load saved session
    final sessionCubit = context.read<SessionCubit>();
    await sessionCubit.load();
    final session = sessionCubit.state;

    if (session != null &&
        session.tunePaths.isNotEmpty &&
        library.state is LibraryLoaded) {
      // Resolve paths → Tune objects from loaded library
      final libraryState = library.state as LibraryLoaded;
      final allTunes = libraryState.tunes;

      final tuneMap = {for (final t in allTunes) t.path: t};
      final queue = session.tunePaths
          .map((p) => tuneMap[p])
          .whereType<Tune>()
          .toList();

      if (queue.isNotEmpty && mounted) {
        context.read<PlaybackBloc>().add(
          RestoreSessionEvent(
            queue: queue,
            currentIndex: session.currentIndex,
            position: session.position,
            shuffleEnabled: session.shuffleEnabled,
            repeatMode: session.repeatMode,
            speed: session.speed,
          ),
        );
      }
    }

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoute.root);
    await context.read<PlaylistCubit>().loadPlaylist();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
