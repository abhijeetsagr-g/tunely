import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/features/library/cubit/library_cubit.dart';
import 'package:tunely/features/playback/bloc/playback_bloc.dart';
import 'package:tunely/features/root/ui/root_screen.dart';
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
      final tunes = (library.state as LibraryLoaded).tunes;
      context.read<StatsCubit>().load(tunes);
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
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const RootScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
