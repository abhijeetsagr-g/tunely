import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/core/extensions/title_case.dart';
import 'package:tunely/core/utlis/fur_duration.dart';
import 'package:tunely/features/lyrics/view/lyrics_test_view.dart';
import 'package:tunely/features/playback/bloc/playback_bloc.dart';
import 'package:tunely/features/playback/view/player_view.dart';
import 'package:tunely/shared/model/tune.dart';
import 'package:tunely/shared/widget/album_art.dart';

class SongTile extends StatelessWidget {
  const SongTile({super.key, required this.tunes, required this.index});
  final List<Tune> tunes;
  final int index;

  @override
  Widget build(BuildContext context) {
    final tune = tunes[index];
    final playback = context.read<PlaybackBloc>();

    return InkWell(
      onTap: () async {
        playback.add(PlayQueueEvent(tunes, startIndex: index));

        await Future.delayed(Duration(seconds: 1));

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                LyricsTestView(tune: playback.state.currentItem!),
          ),
        );
      },
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        leading: AlbumArt(
          id: tune.songId ?? 0,
          size: Size(46, 46),
          type: .AUDIO,
        ),

        title: Text(
          tune.title.toTitleCase(),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            // color: isCurrent ? Theme.of(context).primaryColor : null,
          ),
        ),

        subtitle: Text(
          tune.artist.replaceAll('/', ' • '),
          overflow: TextOverflow.ellipsis,
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
          ],
        ),
      ),
    );
  }
}
