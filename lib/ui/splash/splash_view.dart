import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:tunely/logic/provider/playback/playback_bloc.dart';
import 'package:tunely/logic/provider/query/query_cubit.dart';
import 'package:tunely/logic/provider/query/query_state.dart';
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
    final cubit = context.read<QueryCubit>();
    initialLoad(cubit);
  }

  Future<void> initialLoad(QueryCubit cubit) async {
    final results = await Future.wait([
      cubit.getAllSongs(),
      cubit.initialLoad(),
    ]);
    if (mounted) {
      context.read<PlaybackBloc>().add(
        SongLoaded(results[0] as List<SongModel>),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<QueryCubit, QueryState>(
        listener: (context, state) {
          if (!state.isLoading) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeView()),
            );
          }
        },
        child: CircularProgressIndicator.adaptive(),
      ),
    );
  }
}
