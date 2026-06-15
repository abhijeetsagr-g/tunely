import 'package:flutter/material.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:tunely/core/const/app_route.dart';
import 'package:tunely/core/utlis/settings_arguments.dart';

class GenresTab extends StatelessWidget {
  final List<GenreModel> genres;

  const GenresTab({super.key, required this.genres});

  @override
  Widget build(BuildContext context) {
    if (genres.isEmpty) return const Center(child: Text("No genres found."));
    return CustomScrollView(
      slivers: [
        SliverOverlapInjector(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final genre = genres[index];
            return ListTile(
              leading: const Icon(Icons.label_outline),
              title: Text(
                genre.genre,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Text(
                "${genre.numOfSongs} songs",
                style: Theme.of(context).textTheme.bodySmall,
              ),
              onTap: () => Navigator.pushNamed(
                context,
                AppRoute.genre,
                arguments: GenreSettingsArguments(genre),
              ),
            );
          }, childCount: genres.length),
        ),
      ],
    );
  }
}
