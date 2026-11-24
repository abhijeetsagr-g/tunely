import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/features/settings/cubit/management_cubit.dart';
import 'package:tunely/features/settings/widgets/settings_tile.dart';

const _defaultDelimiters = ['/', ',', ';', '&', '+'];
const _suggestions = ['/', ',', ';', '&', '+', '|', '•', '×'];

class ArtistDelimiterWidget extends StatelessWidget {
  const ArtistDelimiterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final delimiters = context.select<ManagementCubit, List<String>>(
      (c) => c.state.artistDelimiters,
    );

    return SettingsTile(
      title: 'Artist delimiters',
      value: delimiters.isEmpty ? 'None' : delimiters.join('   '),
      onTap: () => _openSheet(context),
    );
  }

  void _openSheet(BuildContext context) {
    final cubit = context.read<ManagementCubit>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) =>
          BlocProvider.value(value: cubit, child: const _DelimiterSheet()),
    );
  }
}

class _DelimiterSheet extends StatefulWidget {
  const _DelimiterSheet();

  @override
  State<_DelimiterSheet> createState() => _DelimiterSheetState();
}

class _DelimiterSheetState extends State<_DelimiterSheet> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _add(ManagementCubit cubit, List<String> current, String raw) {
    final v = raw.trim();
    if (v.isEmpty) return;
    if (current.contains(v)) {
      setState(() => _error = '"$v" is already added');
      return;
    }
    cubit.updateDelimiters([...current, v]);
    _controller.clear();
    setState(() => _error = null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final cubit = context.read<ManagementCubit>();
    final delimiters = context.select<ManagementCubit, List<String>>(
      (c) => c.state.artistDelimiters,
    );
    final isDefault = listEquals(delimiters, _defaultDelimiters);
    final available = _suggestions
        .where((s) => !delimiters.contains(s))
        .toList();

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        24,
        0,
        24,
        24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Artist delimiters',
                      style: theme.textTheme.titleLarge,
                    ),
                    Text(
                      'Split multiple artists in one tag',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isDefault)
                IconButton.filledTonal(
                  tooltip: 'Reset to default',
                  icon: const Icon(Icons.restart_alt_rounded),
                  onPressed: () => cubit.updateDelimiters(_defaultDelimiters),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Active delimiters
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(20),
            ),
            child: delimiters.isEmpty
                ? Row(
                    children: [
                      Icon(
                        Icons.block_rounded,
                        size: 20,
                        color: scheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'No delimiters. Multiple artists won\'t be split.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final d in delimiters)
                            InputChip(
                              label: Text(
                                d,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: scheme.onSecondaryContainer,
                                ),
                              ),
                              backgroundColor: scheme.secondaryContainer,
                              side: BorderSide.none,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              deleteIconColor: scheme.onSecondaryContainer,
                              onDeleted: () => cubit.updateDelimiters(
                                delimiters.where((x) => x != d).toList(),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _Preview(delimiter: delimiters.first),
                    ],
                  ),
          ),

          // Quick add
          if (available.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              'Quick add',
              style: theme.textTheme.labelLarge?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final s in available)
                  ActionChip(
                    avatar: const Icon(Icons.add_rounded, size: 18),
                    label: Text(s),
                    onPressed: () => _add(cubit, delimiters, s),
                  ),
              ],
            ),
          ],

          // Custom input
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  maxLength: 1,
                  textInputAction: TextInputAction.done,
                  onChanged: (_) {
                    if (_error != null) setState(() => _error = null);
                  },
                  onSubmitted: (v) => _add(cubit, delimiters, v),
                  decoration: InputDecoration(
                    labelText: 'Custom delimiter',
                    hintText: 'e.g. |',
                    counterText: '',
                    errorText: _error,
                    filled: true,
                    fillColor: scheme.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 56,
                child: FilledButton.icon(
                  onPressed: () => _add(cubit, delimiters, _controller.text),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add'),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview({required this.delimiter});

  final String delimiter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );

    Widget pill(String t) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(t, style: theme.textTheme.labelMedium),
    );

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 6,
      children: [
        Text('Artist A $delimiter Artist B', style: muted),

        pill('Artist A'),
        pill('Artist B'),
      ],
    );
  }
}
