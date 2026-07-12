import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/shared/service/artist_service.dart';

class ArtistImagePickerSheet extends StatefulWidget {
  const ArtistImagePickerSheet({super.key, required this.artistName});

  final String artistName;

  static Future<String?> show(BuildContext context, String artistName) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ArtistImagePickerSheet(artistName: artistName),
    );
  }

  @override
  State<ArtistImagePickerSheet> createState() => _ArtistImagePickerSheetState();
}

class _ArtistImagePickerSheetState extends State<ArtistImagePickerSheet> {
  late final Future<List<DeezerArtistResult>> _future;

  @override
  void initState() {
    super.initState();
    final service = context.read<ArtistService>();
    _future = service.searchArtists(widget.artistName);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.4,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Choose artist image',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.artistName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<DeezerArtistResult>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final results = snapshot.data;
                  if (results == null || results.isEmpty) {
                    return const Center(child: Text('No images found'));
                  }

                  return GridView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final artist = results[index];
                      return _ArtistImageTile(
                        artist: artist,
                        onTap: () => Navigator.pop(context, artist.pictureXl),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ArtistImageTile extends StatelessWidget {
  const _ArtistImageTile({required this.artist, required this.onTap});

  final DeezerArtistResult artist;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Tooltip(
        message: artist.name,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: artist.pictureXl,
                fit: BoxFit.cover,
                placeholder: (_, _) => Container(
                  color: Colors.grey.shade900,
                  child: const Icon(Icons.music_note, color: Colors.white54),
                ),
                errorWidget: (_, _, _) => Container(
                  color: Colors.grey.shade900,
                  child: const Icon(Icons.broken_image, color: Colors.white54),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                  child: Text(
                    artist.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
