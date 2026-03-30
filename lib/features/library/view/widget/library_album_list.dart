import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/features/library/cubit/library_cubit.dart';
import 'package:tunely/features/library/cubit/library_state.dart';
import 'package:tunely/shared/widgets/album_box.dart';

class LibraryAlbumList extends StatelessWidget {
  const LibraryAlbumList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LibraryCubit, LibraryState>(
      builder: (context, state) {
        final albums = context.read<LibraryCubit>().albums;

        if (albums.isEmpty) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Text(
                "No albums found",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          sliver: SliverGrid.builder(
            itemCount: albums.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 10,
              childAspectRatio: 0.75,
            ),
            itemBuilder: (context, index) {
              return AlbumBox(album: albums[index]);
            },
          ),
        );
      },
    );
  }
}
