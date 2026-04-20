import 'package:flutter/material.dart';
import 'package:tunely/core/extensions/title_case.dart';
import 'package:tunely/shared/model/artist.dart';
import 'package:tunely/shared/widget/artist_avater.dart';

class ArtistCard extends StatelessWidget {
  const ArtistCard({super.key, required this.artist});
  final Artist artist;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // TODO: Move to ARTISTPAGE
      },
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        leading: ArtistAvatar(artist: artist, size: Size(50, 50)),
        title: Text(
          artist.artist.toTitleCase(),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
        ),

        subtitle: Text(
          "${artist.tunesId.length} songs",
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(color: Colors.grey),
        ),
      ),
    );
  }
}
