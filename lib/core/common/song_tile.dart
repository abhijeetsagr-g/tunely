import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/core/common/album_art.dart';
import 'package:tunely/core/config/app_route.dart';
import 'package:tunely/core/extensions/title_case.dart';
import 'package:tunely/core/utlis/fur_duration.dart';
import 'package:tunely/data/model/tune.dart';
import 'package:tunely/logic/provider/playback/playback_bloc.dart';
import 'package:tunely/logic/provider/query/query_cubit.dart';

class SongTile extends StatelessWidget {
  const SongTile({
    super.key,
    required this.tune,

    required this.index,
    required this.tunes,
  });
  final Tune tune;
  final int index;
  final List<Tune> tunes;

  @override
  Widget build(BuildContext context) {
    final isCurrent = context.select<PlaybackBloc, bool>(
      (bloc) => bloc.state.currentSong?.songId == tune.songId,
    );
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 16),
      selected: isCurrent,
      selectedColor: Theme.of(context).primaryColor,
      selectedTileColor: Theme.of(context).primaryColor.withAlpha(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      leading: AlbumArt(id: tune.songId!, size: Size(46, 46), type: .AUDIO),
      title: Text(
        tune.title.toTitleCase(),
        style: TextStyle(fontSize: 14, fontWeight: .bold),
      ),

      subtitle: Text(
        "${tune.artist.toUpperCase()} · ${formatDur(tune.duration)}",
        style: TextStyle(fontSize: 12),
      ),
      trailing: _PopupMenu(tune),
      onTap: () =>
          context.read<PlaybackBloc>().add(PlaySong(index: index, tune: tunes)),
    );
  }
}

class _PopupMenu extends StatelessWidget {
  const _PopupMenu(this.tune);
  final Tune tune;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      padding: EdgeInsets.zero,
      icon: const Icon(Icons.more_vert_outlined),
      itemBuilder: (_) => [
        const PopupMenuItem(value: 'album', child: Text("Go to Album")),
        const PopupMenuItem(value: 'artist', child: Text("Go to Artist")),
      ],
      onSelected: (value) {
        final cubit = context.read<QueryCubit>();
        final bloc = context.read<PlaybackBloc>();
        if (value == 'album') {
          final album = cubit.getAlbumById(tune.albumId!);
          if (album == null) return;
          final tunes = bloc.state.tunes
              .where((t) => t.albumId == tune.albumId)
              .toList();
          Navigator.pushNamed(
            context,
            AppRoutes.album,
            arguments: AlbumViewArgs(album: album, tunes: tunes),
          );
        } else if (value == 'artist') {
          final artist = cubit.getArtistById(tune.artistId!);
          if (artist == null) return;
          Navigator.pushNamed(
            context,
            AppRoutes.generic,
            arguments: GenericViewArgs(
              type: FilterType.artists,
              name: artist.artist,
              id: artist.id,
            ),
          );
        }
      },
    );
  }
}
