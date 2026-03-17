import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/core/common/album_art.dart';
import 'package:tunely/core/extensions/title_case.dart';
import 'package:tunely/core/utlis/fur_duration.dart';
import 'package:tunely/data/model/tune.dart';
import 'package:tunely/logic/provider/playback/playback_bloc.dart';

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
      onTap: () =>
          context.read<PlaybackBloc>().add(PlaySong(index: index, tune: tunes)),
    );
  }
}
