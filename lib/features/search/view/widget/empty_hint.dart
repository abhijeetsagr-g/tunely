import 'package:flutter/material.dart';

class EmptyHint extends StatelessWidget {
  const EmptyHint({
    super.key,
    required this.icon,
    required this.message,
    required this.sub,
  });

  final IconData icon;
  final String message;
  final String sub;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withAlpha(160),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 36, color: cs.onSurface.withAlpha(80)),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: cs.onSurface.withAlpha(180),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            sub,
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurface.withAlpha(100),
            ),
          ),
        ],
      ),
    );
  }
}
