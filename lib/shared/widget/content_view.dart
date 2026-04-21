import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/core/extensions/title_case.dart';
import 'package:tunely/core/utlis/search_tunes.dart';
import 'package:tunely/features/playback/bloc/playback_bloc.dart';
import 'package:tunely/shared/model/tune.dart';
import 'package:tunely/shared/widget/song_tile.dart';

class ContentView extends StatefulWidget {
  const ContentView({
    super.key,
    required this.title,
    required this.tunes,
    required this.artWidget,
    this.subtitleWidgets = const [],
  });

  final String title;
  final List<Tune> tunes;
  final Widget artWidget;
  final List<Widget> subtitleWidgets;

  @override
  State<ContentView> createState() => _ContentViewState();
}

class _ContentViewState extends State<ContentView> {
  final _searchController = TextEditingController();
  List<Tune> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = widget.tunes;
    _searchController.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    setState(() {
      _filtered = SearchFunctions.filterTunes(
        widget.tunes,
        _searchController.text,
      );
    });
  }

  String _formatDuration(double ms) {
    final totalMinutes = ms ~/ 60000;
    if (totalMinutes < 60) return '$totalMinutes min';
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    return minutes == 0 ? '${hours}h' : '${hours}h ${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalDuration = widget.tunes.fold<double>(
      0,
      (sum, tune) => sum + tune.duration.inMilliseconds,
    );
    final albumArtists = widget.tunes
        .expand((tune) => tune.artists)
        .map((artist) => artist)
        .toSet()
        .join(', ');

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: false,
            centerTitle: true,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.keyboard_arrow_down),
            ),
            title: Text(
              widget.title.toTitleCase(),
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  widget.artWidget,
                  const SizedBox(height: 24),
                  Text(
                    widget.title.toTitleCase(),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                      fontSize: 24,
                    ),
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${widget.tunes.length} songs', maxLines: 1),
                      const Text(' | '),
                      Text(_formatDuration(totalDuration), maxLines: 1),
                    ],
                  ),
                  ...widget.subtitleWidgets,
                  const SizedBox(height: 12),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search in ${widget.title.toTitleCase()}',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {
                            context.read<PlaybackBloc>().add(
                              PlayQueueEvent(widget.tunes),
                            );
                          },
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: const Text('Play'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            context.read<PlaybackBloc>().add(
                              ShuffleAllEvent(widget.tunes),
                            );
                          },
                          icon: const Icon(Icons.shuffle_rounded),
                          label: const Text('Shuffle'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () {
                          context.read<PlaybackBloc>().add(
                            AddQueueItemsEvent(widget.tunes),
                          );
                        },
                        child: const Icon(Icons.queue),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 24, top: 12),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => SongTile(index: index, tunes: _filtered),
                childCount: _filtered.length,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 24, left: 20, right: 20),
            sliver: SliverToBoxAdapter(
              child: Text(
                albumArtists,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 4,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
