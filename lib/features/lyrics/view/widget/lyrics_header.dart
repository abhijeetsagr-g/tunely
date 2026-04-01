import 'package:flutter/material.dart';

class LyricsHeader extends StatelessWidget {
  final bool isSynced;
  final ValueChanged<bool> onSyncedChanged;
  final VoidCallback onMoreTap;

  const LyricsHeader({
    super.key,
    required this.isSynced,
    required this.onSyncedChanged,
    required this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.keyboard_arrow_down),
        ),
        Expanded(
          child: Center(
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: true, label: Text("Synced")),
                ButtonSegment(value: false, label: Text("Unsynced")),
              ],
              selected: {isSynced},
              onSelectionChanged: (val) => onSyncedChanged(val.first),
              showSelectedIcon: false,
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return Theme.of(context).colorScheme.primary;
                  }
                  return Colors.transparent;
                }),
                foregroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return Theme.of(context).colorScheme.onPrimary;
                  }
                  return Theme.of(context).colorScheme.primary;
                }),
              ),
            ),
          ),
        ),
        IconButton(onPressed: onMoreTap, icon: const Icon(Icons.more_vert)),
      ],
    );
  }
}
