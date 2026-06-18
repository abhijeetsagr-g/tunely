import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/core/const/app_route.dart';
import 'package:tunely/core/extensions/title_case.dart';
import 'package:tunely/core/utlis/settings_arguments.dart';
import 'package:tunely/features/library/cubit/library_cubit.dart';
import 'package:tunely/shared/model/artist.dart';
import 'package:tunely/shared/widget/artist_avater.dart';

class ArtistAlbumListSliver extends StatelessWidget {
  const ArtistAlbumListSliver({super.key, required this.artists});
  final List<Artist> artists;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(bottom: 100),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.4,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final artist = artists[index];
          return _ArtistGridTile(artist: artist);
        }, childCount: artists.length),
      ),
    );
  }
}

class _ArtistGridTile extends StatelessWidget {
  const _ArtistGridTile({required this.artist});
  final Artist artist;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final fullArtist = context.read<LibraryCubit>().getFullArtist(artist);
    final display = fullArtist ?? artist;

    return InkWell(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoute.artist,
        arguments: ArtistSettingsArguments(display),
      ),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface.withAlpha(180),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ArtistAvatar(artist: display, size: const Size(48, 48)),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                display.artist.toTitleCase(),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
