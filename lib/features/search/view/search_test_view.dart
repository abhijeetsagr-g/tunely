import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/core/utlis/fur_artist_name.dart';
import 'package:tunely/features/music_management/cubit/music_manager_cubit.dart';
import 'package:tunely/features/search/cubit/search_cubit.dart';

class SearchTestView extends StatefulWidget {
  const SearchTestView({super.key});

  @override
  State<SearchTestView> createState() => _SearchTestViewState();
}

class _SearchTestViewState extends State<SearchTestView> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search...',
            border: InputBorder.none,
          ),
          onChanged: (q) => context.read<SearchCubit>().search(q),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _controller.clear();
              context.read<SearchCubit>().clear();
            },
          ),
        ],
      ),
      body: BlocBuilder<SearchCubit, SearchState>(
        builder: (context, state) {
          if (state is SearchIdle) {
            return const Center(
              child: Text(
                'Type to search',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          if (state is SearchLoaded) {
            final r = state.result;
            final isEmpty =
                r.tunes.isEmpty &&
                r.artists.isEmpty &&
                r.albums.isEmpty &&
                r.genres.isEmpty &&
                r.playlists.isEmpty;

            if (isEmpty) {
              return Center(
                child: Text(
                  'No results for "${state.query}"',
                  style: const TextStyle(color: Colors.grey),
                ),
              );
            }

            return ListView(
              children: [
                if (r.tunes.isNotEmpty) ...[
                  _Header('🎵 Songs (${r.tunes.length})'),
                  ...r.tunes.map(
                    (t) => ListTile(
                      leading: const Icon(Icons.music_note),
                      title: Text(
                        t.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        formatArtistName(
                          context
                              .read<ManagementCubit>()
                              .state
                              .artistDelimiters,
                          t.artist,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
                if (r.artists.isNotEmpty) ...[
                  _Header('🎤 Artists (${r.artists.length})'),
                  ...r.artists.map(
                    (a) => ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(a.artist),
                      subtitle: Text('${a.tunesId.length} songs'),
                    ),
                  ),
                ],
                if (r.albums.isNotEmpty) ...[
                  _Header('💿 Albums (${r.albums.length})'),
                  ...r.albums.map(
                    (a) => ListTile(
                      leading: const Icon(Icons.album),
                      title: Text(a.album),
                      subtitle: Text(a.artist ?? ''),
                    ),
                  ),
                ],
                if (r.genres.isNotEmpty) ...[
                  _Header('🎸 Genres (${r.genres.length})'),
                  ...r.genres.map(
                    (g) => ListTile(
                      leading: const Icon(Icons.category),
                      title: Text(g.genre),
                    ),
                  ),
                ],
                if (r.playlists.isNotEmpty) ...[
                  _Header('📋 Playlists (${r.playlists.length})'),
                  ...r.playlists.map(
                    (p) => ListTile(
                      leading: const Icon(Icons.queue_music),
                      title: Text(p.playlist),
                    ),
                  ),
                ],
              ],
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String text;
  const _Header(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }
}
