import 'package:flutter/material.dart';
import 'package:tunely/features/lyrics/model/lrclib_search_result.dart';
import 'package:tunely/features/lyrics/cubit/lyrics_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/features/playback/bloc/playback_bloc.dart';
import 'package:tunely/features/lyrics/view/widget/lyrics_search_result_widget.dart';

void showLrcLibSearchSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider.value(
      value: context.read<LyricsCubit>(),
      child: const LrcLibSearchSheet(),
    ),
  );
}

class LrcLibSearchSheet extends StatefulWidget {
  const LrcLibSearchSheet({super.key});

  @override
  State<LrcLibSearchSheet> createState() => _LrcLibSearchSheetState();
}

class _LrcLibSearchSheetState extends State<LrcLibSearchSheet> {
  late final TextEditingController _controller;
  List<LrcLibSearchResult>? _results;

  @override
  void initState() {
    super.initState();
    final tune = context.read<PlaybackBloc>().state.currentItem;
    _controller = TextEditingController(
      text: tune == null ? '' : '${tune.title} - ${tune.artist}',
    );
    _search();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final cubit = context.read<LyricsCubit>();
    final query = _controller.text.trim();
    setState(() => _results = null);

    if (query.isEmpty) {
      setState(() => _results = []);
      return;
    }

    final sep = query.indexOf(' - ');
    final title = sep == -1 ? query : query.substring(0, sep).trim();
    final artist = sep == -1 ? '' : query.substring(sep + 3).trim();

    final results = await cubit.searchLrclib(title: title, artist: artist);
    if (!mounted) return;
    setState(() => _results = results);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withAlpha(20),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Text(
                  'Search results from LRCLIB',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: TextField(
                  controller: _controller,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _search(),
                  decoration: InputDecoration(
                    hintText: 'Title - Artist',
                    isDense: true,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: _search,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              Expanded(child: _buildBody(theme)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_results == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              'Searching...',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withAlpha(150),
              ),
            ),
          ],
        ),
      );
    }

    if (_results!.isEmpty) {
      return Center(
        child: Text(
          'No results found',
          style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(100)),
        ),
      );
    }

    return ListView.builder(
      itemCount: _results!.length,
      itemBuilder: (context, index) {
        final r = _results![index];
        return GestureDetector(
          onTap: () => context.read<LyricsCubit>().selectSearchResult(r),
          child: LyricsSearchResultWidget(result: r),
        );
      },
    );
  }
}
