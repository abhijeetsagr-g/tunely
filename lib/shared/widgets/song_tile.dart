import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/shared/widgets/album_art.dart';
import 'package:tunely/core/extensions/title_case.dart';
import 'package:tunely/core/utlis/fur_duration.dart';
import 'package:tunely/data/model/tune.dart';
import 'package:tunely/features/player/bloc/playback_bloc.dart';

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
      contentPadding: EdgeInsets.only(left: 8, right: 16),
      selected: isCurrent,
      selectedColor: Theme.of(context).primaryColor,
      selectedTileColor: Theme.of(context).primaryColor.withAlpha(30),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),

      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 200),
            width: 3,
            height: 40,
            decoration: BoxDecoration(
              color: isCurrent
                  ? Theme.of(context).primaryColor
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: 8),
          AlbumArt(id: tune.songId!, size: Size(40, 40), type: .AUDIO),
        ],
      ),

      title: Text(
        tune.title.toTitleCase(),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: isCurrent ? Theme.of(context).primaryColor : null,
        ),
      ),

      subtitle: Text(
        tune.artist.replaceAll('/', ' • '),
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(color: Colors.grey),
      ),

      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            formatDur(tune.duration),
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: Colors.grey),
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.grey),
            onPressed: () {
              // TODO: show bottom sheet / menu
              if (!isCurrent) {
                context.read<PlaybackBloc>().add(AddToQueue(tune));
              }
            },
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
      onTap: () {
        context.read<PlaybackBloc>().add(PlaySong(index: index, tune: tunes));
      },
    );
  }
}
