import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/shared/model/tune.dart';
import 'package:tunely/features/lyrics/cubit/lyric_cubit.dart';

class LyricsSearchSheet extends StatefulWidget {
  final Tune tune;

  const LyricsSearchSheet({super.key, required this.tune});

  static Future<void> show(BuildContext context, Tune tune) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<LyricCubit>(),
        child: LyricsSearchSheet(tune: tune),
      ),
    );
  }

  @override
  State<LyricsSearchSheet> createState() => _LyricsSearchSheetState();
}

class _LyricsSearchSheetState extends State<LyricsSearchSheet> {
  late final TextEditingController _titleController = TextEditingController(
    text: widget.tune.title,
  );
  late final TextEditingController _artistController = TextEditingController(
    text: widget.tune.artist,
  );

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Search Lyrics', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _artistController,
            decoration: const InputDecoration(labelText: 'Artist'),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              context.read<LyricCubit>().reloadLyricsManual(
                widget.tune,
                _titleController.text.trim(),
                _artistController.text.trim(),
              );
              Navigator.pop(context);
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }
}
