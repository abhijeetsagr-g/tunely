import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/features/lyrics/cubit/lyrics_cubit.dart';
import 'package:tunely/features/playback/bloc/playback_bloc.dart';

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
  void dispose() {
    _titleCtrl.dispose();
    _artistCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cubit = context.read<LyricsCubit>();
    final playback = context.read<PlaybackBloc>();
    final state = cubit.state;
    final isLoaded = state is LyricsLoaded;

    _titleCtrl = TextEditingController(text: playback.state.currentItem?.title);
    _artistCtrl = TextEditingController(
      text: playback.state.currentItem?.artist,
    );

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
              // Handle
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withOpacity(0.2),
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

              // search manually
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

              // reload
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

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
