import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/features/playlist/cubit/playlist_cubit.dart';
import 'package:tunely/features/playlist/widgets/field_with_inner_counter.dart';
import 'package:tunely/features/playlist/widgets/playlist_song_list.dart';
import 'package:tunely/shared/model/tune.dart';

class CreatePlaylistView extends StatefulWidget {
  const CreatePlaylistView({super.key, required this.tunes});

  final List<Tune> tunes;

  @override
  State<CreatePlaylistView> createState() => _CreatePlaylistViewState();
}

class _CreatePlaylistViewState extends State<CreatePlaylistView> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController desController = TextEditingController();
  final Set<String> _selectedPaths = {};

  bool get _canSubmit =>
      titleController.text.trim().isNotEmpty || _selectedPaths.isNotEmpty;

  @override
  void initState() {
    super.initState();
    titleController.addListener(_onChanged);
    desController.addListener(_onChanged);
  }

  void _onChanged() => setState(() {});

  void _onSelectionChanged(Set<int> songIds) {
    final byId = {
      for (final t in widget.tunes)
        if (t.songId != null) t.songId!: t.path,
    };
    setState(() {
      _selectedPaths
        ..clear()
        ..addAll(songIds.map((id) => byId[id]).whereType<String>());
    });
  }

  String get _defaultName {
    final now = DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(now.day)}/${two(now.month)}/${two(now.year % 100)}';
  }

  Future<void> _create() async {
    final name = titleController.text.trim().isEmpty
        ? _defaultName
        : titleController.text.trim();
    final description = desController.text.trim();
    await context.read<PlaylistCubit>().createPlaylist(
      name: name,
      description: description.isEmpty ? null : description,
      songPaths: _selectedPaths.toList(),
    );
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  void dispose() {
    titleController.removeListener(_onChanged);
    desController.removeListener(_onChanged);
    titleController.dispose();
    desController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              centerTitle: true,
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.keyboard_arrow_left),
              ),
              title: Text(
                "Create Playlist",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Content
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  FieldWithInnerCounter(
                    controller: titleController,
                    hint: 'Playlist name',
                    icon: Icons.queue_music_rounded,
                    maxLength: 100,
                  ),
                  const SizedBox(height: 16),
                  FieldWithInnerCounter(
                    controller: desController,
                    hint: 'Description',
                    icon: Icons.notes_rounded,
                    maxLength: 300,
                    minLines: 2,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 16),
                  PlaylistSongList(
                    tunes: widget.tunes,
                    onSelectionChanged: _onSelectionChanged,
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          decoration: BoxDecoration(color: Colors.transparent),
          child: FilledButton(
            onPressed: _canSubmit ? _create : null,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text('Create Playlist'),
          ),
        ),
      ),
    );
  }
}
