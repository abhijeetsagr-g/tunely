import 'package:flutter/material.dart';
import 'package:tunely/core/const/app_route.dart';
import 'package:tunely/ui/common/artist_image.dart';

class ArtistChip extends StatelessWidget {
  const ArtistChip({
    super.key,
    required this.artistName,
    this.onTap,
    required this.id,
  });

  final String artistName;
  final int id;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRoute.artist, arguments: id);
      },
      child: Card(
        elevation: 2,
        child: Container(
          padding: const EdgeInsets.fromLTRB(4, 4, 12, 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: [
              ArtistImage(
                artistName: artistName,
                size: 32,
                borderRadius: 16,
                artistId: id,
              ),
              Text(artistName, style: Theme.of(context).textTheme.labelLarge),
            ],
          ),
        ),
      ),
    );
  }
}
