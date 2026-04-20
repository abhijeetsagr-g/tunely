import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AlbumArt extends StatefulWidget {
  const AlbumArt({super.key, this.artUri, required this.size});

  final Uri? artUri;
  final Size size;

  @override
  State<AlbumArt> createState() => _AlbumArtState();
}

class _AlbumArtState extends State<AlbumArt> {
  Uint8List? _bytes;
  late Uri? artUri;
  static const _channel = MethodChannel('tunely/artwork');

  @override
  void initState() {
    super.initState();
    if (widget.artUri == null) {
      artUri = Uri.parse('content://media/external/audio/albumart/0');
    } else {
      artUri = widget.artUri;
    }

    _load();
  }

  @override
  void didUpdateWidget(AlbumArt old) {
    super.didUpdateWidget(old);
    if (old.artUri != widget.artUri) _load();
  }

  Future<void> _load() async {
    try {
      final bytes = await _channel.invokeMethod<Uint8List>(
        'getArtwork',
        widget.artUri.toString(),
      );
      if (mounted) setState(() => _bytes = bytes);
    } catch (_) {
      if (mounted) setState(() => _bytes = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: widget.size.width,
        height: widget.size.height,
        child: _bytes != null
            ? Image.memory(_bytes!, fit: BoxFit.cover, gaplessPlayback: true)
            : _Placeholder(size: widget.size),
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
