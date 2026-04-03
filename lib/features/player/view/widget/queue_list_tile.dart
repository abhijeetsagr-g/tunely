import 'package:flutter/material.dart';
import 'package:tunely/core/extensions/title_case.dart';
import 'package:tunely/data/model/tune.dart';
import 'package:tunely/shared/widgets/album_art.dart';

class QueueListTile extends StatelessWidget {
  const QueueListTile({
    super.key,
    required this.tune,
    required this.position,
    required this.onTap,
  });

  final Tune tune;
  final int position;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Row(
          children: [
            SizedBox(
              width: 28,
              child: Text(
                '$position',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withAlpha(80),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: AlbumArt(
                id: tune.songId!,
                size: const Size(42, 42),
                type: .AUDIO,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tune.title.toTitleCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tune.artist.replaceAll('/', ' • '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withAlpha(120),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.drag_handle_rounded,
              color: colorScheme.onSurface.withAlpha(60),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
