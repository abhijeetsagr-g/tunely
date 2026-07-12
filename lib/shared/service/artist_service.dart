import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DeezerArtistResult {
  final String name;
  final String pictureXl;
  final int? id;

  const DeezerArtistResult({
    required this.name,
    required this.pictureXl,
    this.id,
  });

  factory DeezerArtistResult.fromJson(Map<String, dynamic> json) {
    return DeezerArtistResult(
      name: (json['name'] as String?) ?? '',
      pictureXl: (json['picture_xl'] as String?) ?? '',
      id: json['id'] as int?,
    );
  }
}

class ArtistService {
  static const _prefsKey = 'artist_image_cache';
  static const _placeholderHash = 'd41d8cd98f00b204e9800998ecf8427e';
  static const _maxCacheSize = 500;

  static final Map<String, String?> _cache = {};
  static Future<void>? _loadFuture;

  final http.Client _client;

  ArtistService({http.Client? client}) : _client = client ?? http.Client();

  String _normalize(String name) => name.trim().toLowerCase();

  static bool _isPlaceholder(String? url) =>
      url == null || url.contains(_placeholderHash);

  Future<String?> getImageUrl(String artistName) async {
    final key = _normalize(artistName);

    _loadFuture ??= _load();
    await _loadFuture;

    if (_cache.containsKey(key)) return _cache[key];

    try {
      final results = await searchArtists(artistName);
      String? url;

      for (final result in results) {
        if (_isPlaceholder(result.pictureXl)) continue;
        if (result.name.toLowerCase() == key) {
          url = result.pictureXl;
          break;
        }
        url ??= result.pictureXl;
      }

      _evictIfNeeded();
      _cache[key] = url;
      await _save();
      return url;
    } catch (_) {
      _cache[key] = null;
      await _save();
      return null;
    }
  }

  Future<List<DeezerArtistResult>> searchArtists(String query) async {
    try {
      final uri = Uri.parse(
        'https://api.deezer.com/search/artist?q=${Uri.encodeComponent(_normalize(query))}',
      );
      final res = await _client.get(uri);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final items = data['data'] as List<dynamic>?;
        if (items != null) {
          return items
              .map((e) => DeezerArtistResult.fromJson(e as Map<String, dynamic>))
              .where((a) => a.pictureXl.isNotEmpty && !_isPlaceholder(a.pictureXl))
              .toList();
        }
      }
    } catch (_) {}
    return [];
  }

  Future<void> setImageUrl(String artistName, String url) async {
    final key = _normalize(artistName);
    _loadFuture ??= _load();
    await _loadFuture;

    _cache[key] = url;
    await _save();
  }

  void preFetch(Iterable<String> names) {
    for (final name in names) {
      final key = _normalize(name);
      if (!_cache.containsKey(key)) {
        unawaited(getImageUrl(name).catchError((_) => null));
      }
    }
  }

  static void _evictIfNeeded() {
    if (_cache.length >= _maxCacheSize) {
      final toRemove = (_maxCacheSize * 0.1).ceil();
      final keys = _cache.keys.take(toRemove).toList();
      for (final k in keys) {
        _cache.remove(k);
      }
    }
  }

  static Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null) {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final cleaned = decoded.map(
        (k, v) => MapEntry(k.trim().toLowerCase(), v as String?),
      )..removeWhere((_, v) => _isPlaceholder(v));
      _cache.addAll(cleaned);
    }
  }

  static Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(_cache));
  }
}
