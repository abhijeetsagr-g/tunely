import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/core/config/app_route.dart';
import 'package:tunely/core/extensions/title_case.dart';
import 'package:tunely/logic/provider/playback/playback_bloc.dart';

class SongInfo extends StatelessWidget {
  const SongInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlaybackBloc, PlaybackState>(
      buildWhen: (prev, curr) => prev.currentSong != curr.currentSong,
      builder: (context, state) {
        final tune = state.currentSong;

        if (tune == null) return const SizedBox();

        return GestureDetector(
          onTap: () {
            if (tune.artistId != null) {
              Navigator.pushNamed(
                context,
                AppRoutes.generic,
                arguments: GenericViewArgs(
                  type: .artists,
                  name: tune.artist,
                  id: tune.artistId!,
                ),
              );
            }
          },
          child: SizedBox(
            height: 70,
            child: Column(
              children: [
                Text(
                  tune.title.toTitleCase(),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  tune.artist,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
