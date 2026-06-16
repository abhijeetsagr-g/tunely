import 'package:flutter/material.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:tunely/core/extensions/title_case.dart';
import 'package:tunely/shared/model/tune.dart';
import 'package:tunely/shared/widget/album_art.dart';

class SongPicker extends StatefulWidget {
  final List<Tune> tunes;
  final ValueChanged<Set<int>>? onSelectionChanged;

  const SongPicker({
    super.key,
    required this.tunes,
    this.onSelectionChanged,
  });

  @override
  State<SongPicker> createState() => _SongPickerState();
}

class _SongPickerState extends State<SongPicker> {
  final Set<int> _selected = {};

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: widget.tunes.length,
      itemBuilder: (context, index) {
        final tune = widget.tunes[index];
        final isSelected = _selected.contains(tune.songId);

        return ListTile(
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(
                value: isSelected,
                onChanged: (val) {
                  setState(() {
                    if (val == true) {
                      _selected.add(tune.songId!);
                    } else {
                      _selected.remove(tune.songId);
                    }
                  });
                  widget.onSelectionChanged?.call(Set.from(_selected));
                },
              ),
              AlbumArt(
                id: tune.songId,
                type: ArtworkType.AUDIO,
                size: const Size(46, 46),
              ),
            ],
          ),
          title: Text(
            tune.title.toTitleCase(),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            tune.artists.join(" • "),
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(color: Colors.grey),
          ),
        );
      },
    );
  }
}
