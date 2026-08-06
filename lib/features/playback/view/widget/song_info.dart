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

        return Column(
          mainAxisSize: MainAxisSize.min,
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
            const SizedBox(height: 4),
            ConstrainedBox(
              // Cap artist row(s) instead of clipping via a fixed parent box.
              constraints: const BoxConstraints(maxHeight: 44),
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    for (int i = 0; i < tune.artists.length; i++) ...[
                      GestureDetector(
                        onTap: () {
                          final cubitState = context.read<LibraryCubit>().state;
                          if (cubitState is! LibraryLoaded) return;
                          final artist = cubitState.artists.firstWhere(
                            (element) => tune.artists[i] == element.artist,
                          );
                          Navigator.pushReplacementNamed(
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
              ),
            ),
          ],
        );
      },
    );
  }
}
