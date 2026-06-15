import 'package:flutter/material.dart';
import 'package:tunely/core/const/app_route.dart';
import 'package:tunely/core/extensions/title_case.dart';
import 'package:tunely/core/utlis/settings_arguments.dart';
import 'package:tunely/shared/model/artist.dart';
import 'package:tunely/shared/widget/artist_avater.dart';

class ArtistCard extends StatelessWidget {
  const ArtistCard({super.key, required this.artist, this.onTap});
  final Artist artist;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () {
          onTap?.call();
          Navigator.pushNamed(
            context,
            AppRoute.artist,
            arguments: ArtistSettingsArguments(artist),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: cs.surface.withAlpha(180),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ArtistAvatar(artist: artist, size: const Size(56, 56)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        artist.artist.toTitleCase(),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${artist.tunes.length} ${artist.tunes.length == 1 ? 'song' : 'songs'}",
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  color: cs.onSurfaceVariant.withAlpha(100),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
