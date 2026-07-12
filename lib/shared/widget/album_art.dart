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
  static const _channel = MethodChannel('tunely/artwork');
  static final _cache = <String, Uint8List?>{};

  Uint8List? _bytes;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(AlbumArt old) {
    super.didUpdateWidget(old);
    if (old.artUri != widget.artUri) _load();
  }

  Future<void> _load() async {
    final uri = widget.artUri;
    if (uri == null) {
      if (mounted) setState(() => _bytes = null);
      return;
    }

    final key = uri.toString();

    if (_cache.containsKey(key)) {
      if (mounted) setState(() => _bytes = _cache[key]);
      return;
    }

    if (_loading) return;
    _loading = true;

    try {
      final result = await _channel.invokeMethod<Uint8List>('getArtwork', key);
      _cache[key] = result;
      if (mounted) setState(() => _bytes = result);
    } catch (_) {
      _cache[key] = null;
      if (mounted) setState(() => _bytes = null);
    } finally {
      _loading = false;
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
