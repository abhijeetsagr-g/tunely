import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/core/const/app_route.dart';
import 'package:tunely/features/session/cubit/session_cubit.dart';
import 'package:tunely/shared/model/tune.dart';
import 'package:tunely/data/repository/tune_repository.dart';
import 'package:tunely/features/library/cubit/library_cubit.dart';
import 'package:tunely/features/library/cubit/library_state.dart';
import 'package:tunely/features/player/bloc/playback_bloc.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    context.read<LibraryCubit>().initialLoad();

    // CHANGE THIS TWO
    final repo = context.read<TuneRepository>();
    final playback = context.read<PlaybackBloc>();

    final session = context.read<SessionCubit>();

    await session.load();

    if (!mounted) return;

    if (session.state != null) {
      final state = session.state;
      final queue = state!.tunePaths
          .map((p) => repo.findByPath(p))
          .whereType<Tune>()
          .toList();

      playback.add(PlaySong(index: state.currentIndex, tune: queue));
      playback.add(Seek(state.position));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<LibraryCubit, LibraryState>(
        listenWhen: (previous, current) =>
            previous.isLoading && !current.isLoading,
        listener: (context, state) async {
          final repo = context.read<TuneRepository>();
          final playback = context.read<PlaybackBloc>();
          final sessionCubit = context.read<SessionCubit>();

          final session = sessionCubit.state;

          if (session != null) {
            final queue = session.tunePaths
                .map((p) => repo.findByPath(p))
                .whereType<Tune>()
                .toList();

            if (queue.isNotEmpty) {
              playback.add(
                PlaySong(
                  index: session.currentIndex,
                  tune: queue,
                  autoPlay: false,
                ),
              );
              playback.add(Seek(session.position));
            }
          }

          Navigator.pushReplacementNamed(context, AppRoute.root);
        },
        child: const Center(child: CircularProgressIndicator.adaptive()),
      ),
    );
  }
}
