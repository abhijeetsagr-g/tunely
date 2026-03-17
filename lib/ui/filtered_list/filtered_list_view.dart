import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/core/config/app_route.dart';
import 'package:tunely/logic/provider/query/query_cubit.dart';
import 'package:tunely/ui/filtered_list/widget/album_list.dart';
import 'package:tunely/ui/filtered_list/widget/generic_list.dart';

class FilteredListView extends StatelessWidget {
  const FilteredListView({super.key, required this.type});
  final FilterType type;

  String get _title => switch (type) {
    FilterType.album => "Albums",
    FilterType.playlist => "Playlists",
    FilterType.genres => "Genres",
    FilterType.artists => "Artists",
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_title)),
      body: Builder(
        builder: (context) {
          final cubit = context.read<QueryCubit>();
          return switch (type) {
            FilterType.album => AlbumList(albums: cubit.albums),
            FilterType.playlist => GenericList(
              items: cubit.playlists
                  .map(
                    (p) =>
                        Item(p.playlist, Icons.queue_music, p.numOfSongs, p.id),
                  )
                  .toList(),
              type: type,
            ),
            FilterType.genres => GenericList(
              items: cubit.genres
                  .map((g) => Item(g.genre, Icons.category, g.numOfSongs, g.id))
                  .toList(),
              type: type,
            ),
            FilterType.artists => GenericList(
              items: cubit.artists
                  .map(
                    (a) => Item(
                      a.artist,
                      Icons.person,
                      a.numberOfTracks ?? 0,
                      a.id,
                    ),
                  )
                  .toList(),
              type: type,
            ),
          };
        },
      ),
    );
  }
}
