import 'dart:convert';
import 'package:http/http.dart' as http;

class DeezerService {
  static const _base = 'https://api.deezer.com';

  Future<String?> getArtistImageUrl(String artistName) async {
    try {
      final uri = Uri.parse(
        '$_base/search/artist?q=${Uri.encodeComponent(artistName)}&limit=1',
      );
      final response = await http.get(uri);
      if (response.statusCode != 200) return null;
      final data = jsonDecode(response.body);
      final results = data['data'] as List?;
      if (results == null || results.isEmpty) return null;
      return results.first['picture_medium'] as String?;
    } catch (_) {
      return null;
    }
  }
}
