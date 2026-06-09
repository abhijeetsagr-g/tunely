import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tunely/features/library/cubit/library_cubit.dart';

import 'package:tunely/shared/model/artist.dart';
import 'package:tunely/shared/widget/album_art.dart';

class ArtistAvatar extends StatefulWidget {
  const ArtistAvatar({super.key, required this.artist, required this.size});

  final Artist artist;
  final Size size;

  @override
  State<ArtistAvatar> createState() => _ArtistAvatarState();
}

class _ArtistAvatarState extends State<ArtistAvatar> {
  static const _prefsKey = 'artist_image_cache';
  static Map<String, String?> _cache = {};
  static bool _loaded = false;

  late final Future<String?> _imageFuture;

  @override
  void initState() {
    super.initState();
    _imageFuture = _fetch();
  }

  Future<String?> _fetch() async {
    if (!_loaded) await _load();

    final name = widget.artist.artist;
    if (_cache.containsKey(name)) return _cache[name];

    try {
      final uri = Uri.parse(
        'https://api.deezer.com/search/artist?q=${Uri.encodeComponent(name)}',
      );
      final res = await http.get(uri);

      String? url;
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final items = data['data'] as List<dynamic>?;
        if (items != null && items.isNotEmpty) {
          url = items[0]['picture_medium'] as String?;
        }
      }

      _cache[name] = url;
      _save();
      return url;
    } catch (_) {
      _cache[name] = null;
      _save();
      return null;
    }
  }

  static Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null) {
      _cache = (jsonDecode(raw) as Map<String, dynamic>)
          .map((k, v) => MapEntry(k, v as String?));
    }
    _loaded = true;
  }

  static void _save() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString(_prefsKey, jsonEncode(_cache));
    });
  }

  @override
  Widget build(BuildContext context) {
    final library = context.read<LibraryCubit>();

    int? songId;
    if (library.state is LibraryLoaded) {
      final state = library.state as LibraryLoaded;
      final tune = state.tunes.firstWhere(
        (e) => e.artistId == widget.artist.artistId,
        orElse: () => state.tunes.first,
      );
      songId = tune.songId;
    }

    final fallback = AlbumArt(
      id: songId,
      type: ArtworkType.AUDIO,
      size: widget.size,
    );

    return FutureBuilder<String?>(
      future: _imageFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return fallback;
        }

        final imageUrl = snapshot.data;
        if (imageUrl == null) return fallback;

        return CachedNetworkImage(
          imageUrl: imageUrl,
          width: widget.size.width,
          height: widget.size.height,
          fit: BoxFit.cover,
          placeholder: (_, _) => fallback,
          errorWidget: (_, _, _) => fallback,
        );
      },
    );
  }
}
