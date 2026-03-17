import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/core/common/song_tile.dart';
import 'package:tunely/logic/provider/query/query_cubit.dart';
import 'package:tunely/logic/provider/query/query_state.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController _controller = TextEditingController();

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
              onChanged: (value) => context.read<QueryCubit>().search(value),
            ),
          ),
          Expanded(
            child: BlocBuilder<QueryCubit, QueryState>(
              buildWhen: (prev, curr) => prev.searchResult != curr.searchResult,
              builder: (context, state) {
                final result = state.searchResult;

                if (result == null) return const SizedBox();

                if (result.songs.isEmpty) {
                  return const Center(child: Text('No results'));
                }

                return ListView.builder(
                  itemCount: result.songs.length,
                  itemBuilder: (context, index) {
                    final tune = result.songs[index];
                    return SongTile(
                      tune: tune,
                      index: index,
                      tunes: result.songs,
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
