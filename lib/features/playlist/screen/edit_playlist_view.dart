import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/core/const/app_route.dart';
import 'package:tunely/features/library/cubit/library_cubit.dart';
import 'package:tunely/features/playlist/cubit/playlist_cubit.dart';
import 'package:tunely/features/playlist/model/playlist.dart';
import 'package:tunely/features/playlist/widgets/field_with_inner_counter.dart';
import 'package:tunely/features/playlist/widgets/playlist_song_list/playlist_song_list.dart';

class EditPlaylistView extends StatefulWidget {
  const EditPlaylistView({super.key, required this.playlist});

  final Playlist playlist;

  @override
  State<EditPlaylistView> createState() => _EditPlaylistViewState();
}

class _EditPlaylistViewState extends State<EditPlaylistView> {
  late final TextEditingController _nameController;
  late final TextEditingController _desController;

  /// Selected song paths, in playlist order.
  List<String> _selectedPaths = [];

  bool get _canSubmit =>
      _nameController.text.trim().isNotEmpty || _selectedPaths.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.playlist.name);
    _desController = TextEditingController(
      text: widget.playlist.description ?? '',
    );
    _nameController.addListener(_onChanged);
    _desController.addListener(_onChanged);

    final library = context.read<LibraryCubit>().state;
    final available = library is LibraryLoaded
        ? {for (final t in library.tunes) t.path}
        : const <String>{};
    _selectedPaths = [
      for (final path in widget.playlist.songPaths)
        if (available.isEmpty || available.contains(path)) path,
    ];
  }

  void _onChanged() => setState(() {});

  void _onSelectionChanged(List<String> paths) {
    setState(() => _selectedPaths = List.of(paths));
  }

  void _confirmDelete() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete playlist?'),
        content: Text(
          '"${widget.playlist.name}" and its songs will be permanently removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _deletePlaylist();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePlaylist() async {
    final cubit = context.read<PlaylistCubit>();
    await cubit.deletePlaylist(widget.playlist);
    if (!mounted) return;
    Navigator.of(
      context,
    ).popUntil((route) => route.settings.name == AppRoute.root);
  }

  String get _defaultName {
    final now = DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(now.day)}/${two(now.month)}/${two(now.year % 100)}';
  }

  Future<void> _save() async {
    final name = _nameController.text.trim().isEmpty
        ? _defaultName
        : _nameController.text.trim();
    final description = _desController.text.trim();
    final originalPaths = List<String>.of(widget.playlist.songPaths);
    final newPaths = List<String>.of(_selectedPaths);

    final cubit = context.read<PlaylistCubit>();
    if (name != widget.playlist.name) {
      await cubit.renamePlaylist(widget.playlist, name);
    }
    if (description != (widget.playlist.description ?? '')) {
      await cubit.setDescription(
        widget.playlist,
        description.isEmpty ? null : description,
      );
    }
    if (!listEquals(newPaths, originalPaths)) {
      await cubit.reorderSongs(widget.playlist, newPaths);
    }
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameController.removeListener(_onChanged);
    _desController.removeListener(_onChanged);
    _nameController.dispose();
    _desController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LibraryCubit, LibraryState>(
      builder: (context, libraryState) {
        final theme = Theme.of(context);

        return Scaffold(
          body: SafeArea(
            child: libraryState is LibraryLoaded
                ? CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        backgroundColor: Colors.transparent,
                        centerTitle: true,
                        leading: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.keyboard_arrow_left),
                        ),
                        title: Text(
                          'Edit Playlist',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        actions: [
                          IconButton(
                            onPressed: _confirmDelete,
                            icon: Icon(
                              Icons.delete_outline,
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ],
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        sliver: SliverToBoxAdapter(
                          child: Column(
                            children: [
                              FieldWithInnerCounter(
                                controller: _nameController,
                                hint: 'Playlist name',
                                icon: Icons.queue_music_rounded,
                                maxLength: 100,
                              ),
                              const SizedBox(height: 16),
                              FieldWithInnerCounter(
                                controller: _desController,
                                hint: 'Description',
                                icon: Icons.notes_rounded,
                                maxLength: 300,
                                minLines: 2,
                                maxLines: 4,
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),
                      PlaylistSongList(
                        tunes: libraryState.tunes,
                        initialSelected: _selectedPaths,
                        onSelectionChanged: _onSelectionChanged,
                      ),
                    ],
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
          bottomNavigationBar: libraryState is LibraryLoaded
              ? SafeArea(
                  top: false,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                    decoration: BoxDecoration(color: Colors.transparent),
                    child: FilledButton(
                      onPressed: _canSubmit ? _save : null,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Save'),
                    ),
                  ),
                )
              : null,
        );
      },
    );
  }
}
