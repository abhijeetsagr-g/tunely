import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/shared/model/artist.dart';
import 'package:tunely/shared/service/artist_service.dart';
import 'package:tunely/shared/widget/artist_image_picker_sheet.dart';

class ArtistAvatar extends StatefulWidget {
  const ArtistAvatar({
    super.key,
    required this.artist,
    required this.size,
    this.allowEdit = false,
  });

  final Artist artist;
  final Size size;
  final bool allowEdit;

  @override
  State<ArtistAvatar> createState() => _ArtistAvatarState();
}

class _ArtistAvatarState extends State<ArtistAvatar> {
  late Future<String?> _imageFuture;
  String? _overrideUrl;

  @override
  void initState() {
    super.initState();
    final service = context.read<ArtistService>();
    _imageFuture = service.getImageUrl(widget.artist.artist);
  }

  @override
  void didUpdateWidget(ArtistAvatar old) {
    super.didUpdateWidget(old);
    if (old.artist.artist != widget.artist.artist) {
      _overrideUrl = null;
      final service = context.read<ArtistService>();
      _imageFuture = service.getImageUrl(widget.artist.artist);
    }
  }

  Future<void> _pickImage() async {
    final url = await ArtistImagePickerSheet.show(
      context,
      widget.artist.artist,
    );
    if (url != null && mounted) {
      final service = context.read<ArtistService>();
      await service.setImageUrl(widget.artist.artist, url);
      setState(() => _overrideUrl = url);
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: widget.size.width,
        height: widget.size.height,
        child: _overrideUrl != null
            ? CachedNetworkImage(
                imageUrl: _overrideUrl!,
                width: widget.size.width,
                height: widget.size.height,
                fit: BoxFit.cover,
                placeholder: (_, _) => _Placeholder(size: widget.size),
                errorWidget: (_, _, _) => _Placeholder(size: widget.size),
              )
            : FutureBuilder<String?>(
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

    if (!widget.allowEdit) return child;

    return GestureDetector(
      onLongPress: _pickImage,
      child: child,
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
