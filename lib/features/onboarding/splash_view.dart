import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/core/const/app_route.dart';
import 'package:tunely/data/model/tune.dart';
import 'package:tunely/data/repository/tune_repository.dart';
import 'package:tunely/features/history/history_cubit.dart';
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
    final playback = context.read<PlaybackBloc>();
    final repo = context.read<TuneRepository>();
    final session = context.read<HistoryCubit>().lastSession;

    await Future.wait([
      context.read<HistoryCubit>().load(),
      Future.delayed(const Duration(seconds: 1)),
    ]);

    if (!mounted) return;

    await context.read<HistoryCubit>().load();
    if (session != null) {
      final queue = session.queuePaths
          .map((p) => repo.findByPath(p))
          .whereType<Tune>()
          .toList();

      if (queue.isNotEmpty) {
        final index = session.queuePaths.indexOf(session.currentPath);
        playback.add(
          PlaySong(tune: queue, index: index < 0 ? 0 : index, autoPlay: false),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<LibraryCubit, LibraryState>(
        listenWhen: (previous, current) =>
            previous.isLoading && !current.isLoading,
        listener: (context, state) {
          Navigator.pushReplacementNamed(context, AppRoute.root);
        },
        child: const Center(child: CircularProgressIndicator.adaptive()),
      ),
    );
  }
}
