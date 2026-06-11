import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/features/library/cubit/library_cubit.dart';
import 'package:tunely/features/playback/bloc/playback_bloc.dart';
import 'package:tunely/ui/shell/root_view.dart';
import 'package:tunely/features/session/cubit/session_cubit.dart';
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
    _init();
  }

  Future<void> _init() async {
    await Future.wait([
      context.read<LibraryCubit>().initialLoad(),
      context.read<SessionCubit>().load(),
    ]);

    if (!mounted) return;

    final libraryState = context.read<LibraryCubit>().state;
    if (libraryState is LibraryLoaded) {
      final session = context.read<SessionCubit>().state;
      if (session != null && session.tunePaths.isNotEmpty) {
        final pathToTune = {for (final t in libraryState.tunes) t.path: t};
        final queue = session.tunePaths
            .map((p) => pathToTune[p])
            .whereType<Tune>()
            .toList();
        if (queue.isNotEmpty) {
          final index = session.currentIndex.clamp(0, queue.length - 1);
          context.read<PlaybackBloc>().add(
            RestoreSessionEvent(
              queue: queue,
              currentIndex: index,
              position: session.position,
              shuffleEnabled: session.shuffleEnabled,
              repeatMode: session.repeatMode,
              speed: session.speed,
            ),
          );
        }
      }
    }

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const RootView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 200,
              width: 200,
              child: Image.asset('assets/icon/icon.png'),
            ),
            const SizedBox(height: 100),
            const CircularProgressIndicator.adaptive(),
          ],
        ),
      ),
    );
  }
}
