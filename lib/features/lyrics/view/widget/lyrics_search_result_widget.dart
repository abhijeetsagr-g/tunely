import 'package:flutter/material.dart';
import 'package:tunely/core/utlis/fur_duration.dart';
import 'package:tunely/features/lyrics/model/lrclib_search_result.dart';

class LyricsSearchResultWidget extends StatelessWidget {
  const LyricsSearchResultWidget({super.key, required this.result});
  final LrcLibSearchResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.trackName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        result.artistName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (result.albumName.isNotEmpty) ...[
                        const SizedBox(height: 1),
                        Text(
                          result.albumName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant.withValues(
                              alpha: 0.6,
                            ),
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  formatDur(Duration(seconds: result.duration.toInt())),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              children: [
                if (result.instrumental)
                  _Chip(
                    label: 'Instrumental',
                    color: colorScheme.tertiaryContainer,
                    textColor: colorScheme.onTertiaryContainer,
                  )
                else ...[
                  if (result.syncedLyrics != null)
                    _Chip(
                      label: 'Synced',
                      color: colorScheme.primaryContainer,
                      textColor: colorScheme.onPrimaryContainer,
                    ),
                  if (result.plainLyrics != null)
                    _Chip(
                      label: 'Plain',
                      color: colorScheme.secondaryContainer,
                      textColor: colorScheme.onSecondaryContainer,
                    ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.color,
    required this.textColor,
  });
  final String label;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }
}
