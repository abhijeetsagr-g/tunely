import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:tunely/features/library/cubit/library_cubit.dart';
import 'package:tunely/features/root/ui/view/home/widget/home_sections.dart';
import 'package:tunely/shared/widget/album_card.dart';

class RecommendedAlbums extends StatefulWidget {
  const RecommendedAlbums({super.key});

  @override
  State<RecommendedAlbums> createState() => _RecommendedAlbumsState();
}

class _RecommendedAlbumsState extends State<RecommendedAlbums> {
  List<AlbumModel> _picked = [];

  void _reshuffle(List<AlbumModel> albums) {
    setState(() {
      _picked = ([...albums]..shuffle()).take(5).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: BlocBuilder<LibraryCubit, LibraryState>(
        buildWhen: (prev, curr) => curr is LibraryLoaded,
        builder: (context, state) {
          if (state is! LibraryLoaded) return const SizedBox();

          // Populate on first build
          if (_picked.isEmpty) {
            _picked = ([...state.albums]..shuffle()).take(5).toList();
          }

          final child = _picked.isEmpty
              ? const SizedBox(
                  height: 220,
                  child: Center(child: Text('No albums found')),
                )
              : SizedBox(
                  height: 200,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _picked.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 20),
                    itemBuilder: (context, i) => AlbumCard(album: _picked[i]),
                  ),
                );

          return HomeSections(
            headline: 'Recommended Albums',
            onTap: () => _reshuffle(state.albums),
            child: child,
          );
        },
      ),
    );
  }
}
