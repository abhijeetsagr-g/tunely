import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/core/config/app_route.dart';
import 'package:tunely/logic/provider/playback/playback_bloc.dart';
import 'package:tunely/logic/provider/query/query_cubit.dart';

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
    final songs = await cubit.getAllSongs();
    await cubit.initialLoad();
    if (mounted) {
      final bloc = context.read<PlaybackBloc>();
      bloc.add(SongLoaded(songs));
      bloc.add(SortTunes(.recentlyAdded));

      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: CircularProgressIndicator.adaptive()));
  }
}
