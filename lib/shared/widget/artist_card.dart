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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            onTap?.call();
            Navigator.pushNamed(
              context,
              AppRoute.artist,
              arguments: ArtistSettingsArguments(artist),
            );
          },
          borderRadius: BorderRadius.circular(18),
          splashColor: cs.primary.withAlpha(20),
          highlightColor: cs.primary.withAlpha(10),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: cs.surfaceContainerHigh,
              border: Border.all(color: cs.outlineVariant.withAlpha(60)),
              boxShadow: [
                BoxShadow(
                  color: cs.shadow.withAlpha(15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Hero(
                    tag: 'artist-${artist.artist}',
                    child: ArtistAvatar(
                      artist: artist,
                      size: const Size(56, 56),
                    ),
                  ),
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
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.2,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: cs.primaryContainer.withAlpha(120),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "${artist.tunes.length} ${artist.tunes.length == 1 ? 'song' : 'songs'}",
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: cs.onPrimaryContainer,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: cs.surfaceContainerHighest,
                    ),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
