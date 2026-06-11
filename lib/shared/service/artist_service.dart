import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ArtistService {
  static const _prefsKey = 'artist_image_cache';
  static const _placeholderHash = 'd41d8cd98f00b204e9800998ecf8427e';
  static Map<String, String?> _cache = {};
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
          for (final item in items) {
            final candidate =
                (item as Map<String, dynamic>)['picture_medium'] as String?;
            if (!_isPlaceholder(candidate)) {
              url = candidate;
              break;
            }
          }
        }
      }

      _cache[key] = url;
      _save();
      return url;
    } catch (_) {
      _cache[key] = null;
      _save();
      return null;
    }
  }

  void preFetch(Iterable<String> names) {
    for (final name in names) {
      final key = _normalize(name);
      if (!_cache.containsKey(key)) {
        getImageUrl(name);
      }
    }
  }

  static Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null) {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      _cache = decoded.map(
        (k, v) => MapEntry(k.trim().toLowerCase(), v as String?),
      );
      _cache.removeWhere((_, v) => _isPlaceholder(v));
    }
  }

  static void _save() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString(_prefsKey, jsonEncode(_cache));
    });
  }
}
