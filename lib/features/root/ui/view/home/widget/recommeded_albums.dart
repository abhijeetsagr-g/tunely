import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:tunely/features/library/cubit/library_cubit.dart';
import 'package:tunely/shared/widget/album_art.dart';
import 'package:tunely/features/root/ui/view/home/widget/home_sections.dart';

class RecommendedAlbums extends StatelessWidget {
  const RecommendedAlbums({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LibraryCubit, LibraryState>(
      buildWhen: (prev, curr) => curr is LibraryLoaded,
      builder: (context, state) {
        if (state is! LibraryLoaded) return const SizedBox();

        final albums = [...state.albums]..shuffle();
        final picked = albums.take(5).toList();

        final child = picked.isEmpty
            ? const SizedBox(
                height: 220,
                child: Center(child: Text('No albums found')),
              )
            : SizedBox(
                height: 200,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: picked.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 20),
                  itemBuilder: (context, i) => _AlbumCard(album: picked[i]),
                ),
              );

        return HomeSections(
          headline: 'Recommended Albums',
          // TODO: Open Library
          onTap: () {},
          child: child,
        );
      },
    );
  }
}

class _AlbumCard extends StatelessWidget {
  const _AlbumCard({required this.album});
  final AlbumModel album;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AlbumArt(id: album.id, size: Size(120, 120), type: ArtworkType.ALBUM),
        const SizedBox(height: 4),
        SizedBox(
          width: 90,
          child: Text(
            album.album,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 90,
          child: Text(
            album.artist?.replaceAll('/', ' • ') ?? "Unknown Artist",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ),
      ],
    );
  }
}
