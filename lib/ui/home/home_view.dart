import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:tunely/logic/bloc/playback/playback_bloc.dart';
import 'package:tunely/logic/service/audio_query_service.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final AudioQueryService _service = AudioQueryService();
  List<SongModel> songs = [];

  @override
  void initState() {
    super.initState();
    loadSongs();
  }

  Future<void> loadSongs() async {
    songs = await _service.getSong();

    if (!mounted) return;
    context.read<PlaybackBloc>().add(SongLoaded(songs));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<PlaybackBloc, PlaybackState>(
        builder: (context, state) {
          if (state.tunes.isEmpty) {
            return const Center(child: Text("No songs found"));
          }

          return ListView.builder(
            itemCount: state.tunes.length,
            itemBuilder: (context, index) {
              final tune = state.tunes[index];

              return ListTile(
                textColor: state.currentSong == tune ? Colors.blue : null,
                title: Text(tune.title),
                subtitle: Text(tune.artist),
                onTap: () {
                  context.read<PlaybackBloc>().add(
                    PlaySong(index: index, tune: state.tunes),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
