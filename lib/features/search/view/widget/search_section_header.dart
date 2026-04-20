import 'package:flutter/material.dart';

class SearchSectionHeader extends StatelessWidget {
  const SearchSectionHeader({
    super.key,
    required this.label,
    required this.count,
    required this.expanded,
    required this.onToggle,
  });

  final String label;
  final int count;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return SliverToBoxAdapter(
      child: InkWell(
        onTap: onToggle,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 16, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // accent bar
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 3,
                height: expanded ? 18 : 12,
                decoration: BoxDecoration(
                  color: expanded ? cs.primary : cs.onSurface.withAlpha(60),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$count',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.onSurface.withAlpha(160),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              AnimatedRotation(
                turns: expanded ? 0 : -0.25,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: cs.onSurface.withAlpha(120),
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
