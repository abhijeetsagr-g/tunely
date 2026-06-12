import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/features/music_management/cubit/music_manager_cubit.dart';

class ArtistDelimiterWidget extends StatelessWidget {
  const ArtistDelimiterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<ManagementCubit>();
    final delimiters = cubit.state.artistDelimiters;
    final theme = Theme.of(context);

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Artist Delimiters', style: theme.textTheme.titleSmall),
                const Spacer(),
                Text('${delimiters.length}', style: theme.textTheme.labelSmall),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Characters that separate multiple artists in a single tag.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final d in delimiters)
                  Chip(
                    label: Text(d, style: const TextStyle(fontSize: 16)),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () => cubit.updateDelimiters(
                      delimiters.where((x) => x != d).toList(),
                    ),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ActionChip(
                  label: const Icon(Icons.add, size: 18),
                  onPressed: () => _addDelimiter(context, cubit),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _addDelimiter(BuildContext context, ManagementCubit cubit) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add delimiter'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 1,
          decoration: const InputDecoration(
            hintText: 'e.g. |',
            counterText: '',
          ),
          onSubmitted: (v) {
            if (v.isNotEmpty) {
              cubit.updateDelimiters([...cubit.state.artistDelimiters, v]);
            }
            Navigator.pop(ctx);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final v = controller.text.trim();
              if (v.isNotEmpty) {
                cubit.updateDelimiters([...cubit.state.artistDelimiters, v]);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
