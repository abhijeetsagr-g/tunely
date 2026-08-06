import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AlbumArt extends StatefulWidget {
  const AlbumArt({
    super.key,
    this.artUri,
    required this.size,
    this.borderRadius = 16,
  });

  final Uri? artUri;
  final Size size;
  final double borderRadius;

  @override
  State<AlbumArt> createState() => _AlbumArtState();
}

class _AlbumArtState extends State<AlbumArt> {
  static const _channel = MethodChannel('tunely/artwork');
  static final _cache = <String, Uint8List?>{};

  Uint8List? _bytes;
  bool _loading = false;
  late double _borderRadius;

  @override
  void initState() {
    super.initState();
    _borderRadius = widget.borderRadius;
    _load();
  }

  @override
  void didUpdateWidget(AlbumArt old) {
    super.didUpdateWidget(old);
    if (old.artUri != widget.artUri) _load();
    _borderRadius = old.borderRadius;
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
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(
        begin: _borderRadius,
        end: widget.borderRadius,
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      builder: (context, radius, child) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: SizedBox(
            width: widget.size.width,
            height: widget.size.height,
            child: _bytes != null
                ? Image.memory(_bytes!, fit: BoxFit.cover, gaplessPlayback: true)
                : _Placeholder(
                    size: widget.size,
                    borderRadius: radius,
                  ),
          ),
        );
      },
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.size, required this.borderRadius});
  final Size size;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: const Icon(Icons.music_note, color: Colors.white54),
    );
  }
}
