import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/features/playback/bloc/playback_bloc.dart';
import 'package:tunely/features/root/ui/view/splash/splash_view.dart';
import 'package:tunely/features/session/cubit/session_cubit.dart';
import 'package:tunely/features/session/model/queue_session_model.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // Save queue/index/shuffle/repeat changes
        BlocListener<PlaybackBloc, PlaybackState>(
          listenWhen: (prev, curr) =>
              prev.queue != curr.queue ||
              prev.currentIndex != curr.currentIndex ||
              prev.shuffleEnabled != curr.shuffleEnabled ||
              prev.repeatMode != curr.repeatMode,
          listener: (context, state) {
            if (state.queue.isEmpty) return;
            final session = QueueSessionModel(
              tunePaths: state.queue.map((t) => t.path).toList(),
              currentIndex: state.currentIndex ?? 0,
              shuffleEnabled: state.shuffleEnabled,
              repeatMode: state.repeatMode,
              position: state.position, // last known
              speed: state.speed,
            );
            context.read<SessionCubit>().save(session);
          },
        ),

        // Save position on pause for more accuracy
        BlocListener<PlaybackBloc, PlaybackState>(
          listenWhen: (prev, curr) =>
              prev.isPlaying != curr.isPlaying && !curr.isPlaying,
          listener: (context, state) {
            final current = context.read<SessionCubit>().state;
            if (current == null) return;
            final session = QueueSessionModel(
              tunePaths: current.tunePaths,
              currentIndex: current.currentIndex,
              shuffleEnabled: current.shuffleEnabled,
              repeatMode: current.repeatMode,
              position: state.position,
              speed: current.speed,
            );

            context.read<SessionCubit>().save(session);
          },
        ),
      ],

      child: MaterialApp(
        themeMode: .dark,
        darkTheme: ThemeData.dark(),
        home: SplashView(),
      ),
    );
  }
}
