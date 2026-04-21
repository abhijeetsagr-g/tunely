// _add_songs_sheet.dart (private, same file)

import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:tunely/core/extensions/title_case.dart';
import 'package:tunely/features/playlist/cubit/playlist_cubit.dart';
import 'package:tunely/shared/model/tune.dart';

class AddSongsSheet extends StatefulWidget {
  final PlaylistModel playlist;
  final List<Tune> tunes;
  final PlaylistCubit cubit;

  const AddSongsSheet({
    super.key,
    required this.playlist,
    required this.tunes,
    required this.cubit,
  });

  @override
  State<AddSongsSheet> createState() => _AddSongsSheetState();
}

class _AddSongsSheetState extends State<AddSongsSheet> {
  String _query = '';

  List<Tune> get _filtered => widget.tunes
      .where((t) => t.title.toLowerCase().contains(_query.toLowerCase()))
      .toList();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      expand: false,
      builder: (_, scrollController) => Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              autofocus: true,
              decoration: const InputDecoration(
                hintText: "Search songs...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: _filtered.length,
              itemBuilder: (_, index) {
                final tune = _filtered[index];
                return ListTile(
                  title: Text(
                    tune.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(tune.artist.toTitleCase(), maxLines: 1),
                  trailing: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      widget.cubit.addToPlaylist(widget.playlist.id, tune);
                      Navigator.pop(context);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
