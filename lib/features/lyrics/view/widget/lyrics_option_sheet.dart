import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/features/lyrics/cubit/lyrics_cubit.dart';
import 'package:tunely/features/lyrics/view/widget/song_picker_sheet.dart';
import 'package:tunely/features/playback/bloc/playback_bloc.dart';
import 'package:tunely/shared/model/tune.dart';

void showLyricsOptionsSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider.value(
      value: context.read<LyricsCubit>(),
      child: const LyricsOptionSheet(),
    ),
  );
}

class LyricsOptionSheet extends StatefulWidget {
  const LyricsOptionSheet({super.key});

  @override
  State<LyricsOptionSheet> createState() => _LyricsOptionSheetState();
}

class _LyricsOptionSheetState extends State<LyricsOptionSheet> {
  late TextEditingController _titleCtrl;
  late TextEditingController _artistCtrl;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController();
    _artistCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _artistCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickLrcFile(LyricsCubit cubit) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['lrc'],
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.single;
    String content;
    if (file.path != null) {
      content = await File(file.path!).readAsString();
    } else {
      final bytes = await file.readAsBytes();
      content = String.fromCharCodes(bytes);
    }

    if (!mounted) return;
    cubit.importLrc(content);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cubit = context.read<LyricsCubit>();
    final playback = context.read<PlaybackBloc>();
    final state = cubit.state;
    final isLoaded = state is LyricsLoaded;
    final currentItem = playback.state.currentItem;

    _titleCtrl.text = currentItem?.title ?? '';
    _artistCtrl.text = currentItem?.artist ?? '';

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Text(
                  'Lyrics Options',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              // Song picker from library
              ListTile(
                leading: const Icon(Icons.library_music_rounded),
                title: const Text('Pick song from library'),
                subtitle: const Text('Browse lyrics for any song'),
                onTap: () {
                  Navigator.pop(context);
                  showSongPickerSheet(
                    context,
                    onSelected: (Tune tune) => cubit.fetchForTune(tune),
                  );
                },
              ),

              // search manually on LRCLIB
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _titleCtrl,
                        enabled: isLoaded,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          isDense: true,
                          labelText: 'Title',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _artistCtrl,
                        enabled: isLoaded,
                        textInputAction: TextInputAction.search,
                        decoration: const InputDecoration(
                          isDense: true,
                          labelText: 'Artist',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton.filledTonal(
                      icon: const Icon(Icons.search_rounded, size: 20),
                      onPressed: () {
                        if (isLoaded) {
                          cubit.reloadManual(_titleCtrl.text, _artistCtrl.text);
                        }
                      },
                    ),
                  ],
                ),
              ),

              // reload from LRCLIB
              ListTile(
                enabled: isLoaded,
                leading: const Icon(Icons.refresh_rounded),
                title: const Text('Reload from LRCLIB'),
                subtitle: const Text('Clears cache and re-fetches'),
                onTap: isLoaded
                    ? () {
                        cubit.reload();
                        Navigator.pop(context);
                      }
                    : null,
              ),

              // import .lrc file
              ListTile(
                leading: const Icon(Icons.upload_file_rounded),
                title: const Text('Import .lrc file'),
                subtitle: const Text('Load from device storage'),
                onTap: () => _pickLrcFile(cubit),
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
