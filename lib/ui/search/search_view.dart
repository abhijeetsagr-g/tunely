import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/core/common/song_tile.dart';
import 'package:tunely/data/model/tune.dart';
import 'package:tunely/logic/provider/playback/playback_bloc.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  List<Tune> _filter(List<Tune> tunes) {
    if (_query.isEmpty) return [];

    return tunes.where((tune) {
      final title = tune.title.toLowerCase();
      final artist = tune.artist.toLowerCase();
      final album = tune.album.toLowerCase();
      final q = _query.toLowerCase();

      return title.contains(q) || artist.contains(q) || album.contains(q);
    }).toList();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Search songs...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _query = value;
                });
              },
            ),
          ),

          Expanded(
            child: BlocBuilder<PlaybackBloc, PlaybackState>(
              buildWhen: (prev, curr) => prev.tunes != curr.tunes,
              builder: (context, state) {
                final results = _filter(state.tunes);

                if (_query.isEmpty) {
                  return const SizedBox();
                }

                if (results.isEmpty) {
                  return const Center(child: Text('No results'));
                }

                return ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final tune = results[index];
                    final originalIndex = state.tunes.indexOf(tune);

                    return SongTile(
                      index: originalIndex,
                      tunes: state.tunes,
                      tune: tune,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
