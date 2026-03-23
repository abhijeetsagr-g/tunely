import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/data/model/tune.dart';
import 'package:tunely/data/repository/tune_repository.dart';
import 'package:tunely/logic/provider/history/history_cubit.dart';
import 'package:tunely/logic/provider/library/library_cubit.dart';
import 'package:tunely/logic/provider/library/library_state.dart';
import 'package:tunely/logic/provider/playback/playback_bloc.dart';
import 'package:tunely/ui/home/home_view.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    context.read<LibraryCubit>().initialLoad();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<LibraryCubit, LibraryState>(
        listenWhen: (prev, curr) => prev.isLoading && !curr.isLoading,
        listener: (context, state) async {
          if (state.errorMessage.isNotEmpty) {
            // TODO: SHOW SNACKBAR
            return;
          }

          await context.read<HistoryCubit>().load();

          final session = context.read<HistoryCubit>().lastSession;
          if (session != null) {
            final repo = context.read<TuneRepository>();
            final queue = session.queuePaths
                .map((p) => repo.findByPath(p))
                .whereType<Tune>()
                .toList();
            if (queue.isNotEmpty) {
              final index = session.queuePaths.indexOf(session.currentPath);
              context.read<PlaybackBloc>().add(
                PlaySong(tune: queue, index: index < 0 ? 0 : index),
              );
              await Future.delayed(const Duration(milliseconds: 500));
              if (!mounted) return;
              context.read<PlaybackBloc>().add(
                Seek(Duration(milliseconds: session.positionMs)),
              );
              context.read<PlaybackBloc>().add(Pause());
            }
          }

          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeView()),
            );
          }
        },
        child: const Center(child: CircularProgressIndicator.adaptive()),
      ),
    );
  }
}
