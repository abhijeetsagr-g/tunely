import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/core/const/app_route.dart';
import 'package:tunely/core/extensions/title_case.dart';
import 'package:tunely/features/player/bloc/playback_bloc.dart';

class SongInfo extends StatelessWidget {
  const SongInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlaybackBloc, PlaybackState>(
      buildWhen: (prev, curr) => prev.currentSong != curr.currentSong,
      builder: (context, state) {
        final tune = state.currentSong;
        if (tune == null) return const SizedBox();

        return SizedBox(
          height: 70,
          child: Column(
            children: [
              Text(
                tune.title.toTitleCase(),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),

              Wrap(
                alignment: WrapAlignment.center,
                children:
                    tune.artist
                        .split('/')
                        .map((a) {
                          final name = a.trim();
                          return GestureDetector(
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoute.artist,
                              arguments: name,
                            ),
                            child: Text(
                              name,
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(color: Colors.grey),
                            ),
                          );
                        })
                        .expand((widget) sync* {
                          yield widget;
                          yield Text(
                            ' • ',
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(color: Colors.grey),
                          );
                        })
                        .toList()
                      ..removeLast(),
              ),
            ],
          ),
        );
      },
    );
  }
}
