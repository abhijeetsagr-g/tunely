import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tunely/shared/model/artist.dart';
import 'package:tunely/shared/service/artist_service.dart';

class ArtistAvatar extends StatefulWidget {
  const ArtistAvatar({super.key, required this.artist, required this.size});

  final Artist artist;
  final Size size;

  @override
  State<ArtistAvatar> createState() => _ArtistAvatarState();
}

class _ArtistAvatarState extends State<ArtistAvatar> {
  final _service = ArtistService();
  late Future<String?> _imageFuture;

  @override
  void initState() {
    super.initState();
    _imageFuture = _service.getImageUrl(widget.artist.artist);
  }

  @override
  void didUpdateWidget(ArtistAvatar old) {
    super.didUpdateWidget(old);
    if (old.artist.artist != widget.artist.artist) {
      _imageFuture = _service.getImageUrl(widget.artist.artist);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: widget.size.width,
        height: widget.size.height,
        child: FutureBuilder<String?>(
          future: _imageFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return _Placeholder(size: widget.size);
            }

            final imageUrl = snapshot.data;
            if (imageUrl == null) {
              return _Placeholder(size: widget.size);
            }

            return CachedNetworkImage(
              imageUrl: imageUrl,
              width: widget.size.width,
              height: widget.size.height,
              fit: BoxFit.cover,
              placeholder: (_, _) => _Placeholder(size: widget.size),
              errorWidget: (_, _, _) => _Placeholder(size: widget.size),
            );
          },
        ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.size});
  final Size size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(Icons.music_note, color: Colors.white54),
    );
  }
}
