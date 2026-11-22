import 'package:flutter/material.dart';

class ShowAllToPage extends StatelessWidget {
  const ShowAllToPage({
    super.key,
    required this.appRoute,
    required this.description,
  });
  final String appRoute;
  final String description;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Material(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.of(context).pushNamed(appRoute),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(Icons.play_circle_fill, color: colors.onPrimaryContainer),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    description,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: colors.onPrimaryContainer,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: colors.onPrimaryContainer,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
