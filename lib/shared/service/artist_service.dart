import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
      final uri = Uri.parse(
        'https://api.deezer.com/search/artist?q=${Uri.encodeComponent(key)}',
      );
      final res = await _client.get(uri);

      String? url;

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final items = data['data'] as List<dynamic>?;

        if (items != null) {
          String? exactMatch;
          String? fuzzyFallback;

          for (final item in items) {
            final map = item as Map<String, dynamic>;
            final resultName = (map['name'] as String?)?.trim().toLowerCase();
            final candidate = map['picture_xl'] as String?;

            if (_isPlaceholder(candidate)) continue;

            if (resultName == key) {
              exactMatch = candidate;
              break;
            }
            fuzzyFallback ??= candidate;
          }

          url = exactMatch ?? fuzzyFallback;
        }
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
      // remove oldest 10% when limit hit
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
