import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/core/const/app_route.dart';
import 'package:tunely/core/extensions/title_case.dart';
import 'package:tunely/core/utlis/settings_arguments.dart';
import 'package:tunely/features/library/cubit/library_cubit.dart';
import 'package:tunely/features/playback/bloc/playback_bloc.dart';

class SongInfo extends StatelessWidget {
  const SongInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlaybackBloc, PlaybackState>(
      buildWhen: (prev, curr) => prev.currentItem != curr.currentItem,
      builder: (context, state) {
        final tune = state.currentItem;
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
                children: [
                  for (int i = 0; i < tune.artists.length; i++) ...[
                    GestureDetector(
                      onTap: () {
                        final loaded =
                            context.read<LibraryCubit>().state as LibraryLoaded;
                        final artist = loaded.artists.firstWhere(
                          (element) => tune.artists[i] == element.artist,
                        );

                        Navigator.pushNamed(
                          context,
                          AppRoute.artist,
                          arguments: ArtistSettingsArguments(artist),
                        );
                      },
                      child: Text(
                        tune.artists[i],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(
                          context,
                        ).textTheme.labelLarge?.copyWith(color: Colors.grey),
                      ),
                    ),
                    if (i < tune.artists.length - 1)
                      Text(
                        ' • ',
                        style: Theme.of(
                          context,
                        ).textTheme.labelLarge?.copyWith(color: Colors.grey),
                      ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
