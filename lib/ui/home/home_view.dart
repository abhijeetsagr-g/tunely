import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/logic/provider/playback/playback_bloc.dart';
import 'package:tunely/ui/player/player_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

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

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PlayerView()),
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
