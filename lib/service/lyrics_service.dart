import 'dart:convert';

import 'package:tunely/data/model/lyric_line.dart';
import 'package:tunely/data/model/lyric_result.dart';
import 'package:tunely/data/model/tune.dart';
import 'package:tunely/data/repository/lyrics_repository.dart';
import 'package:http/http.dart' as http;

class LyricsService {
  final LyricsRepository _repository;
  final _client = http.Client();
  static const _base = 'https://lrclib.net/api';

  LyricsService(this._repository);

  Future<LyricResult?> fetchLyrics(Tune tune) async {
    final key = tune.songId.toString();
    if (_repository.exists(key)) {
      return _repository.get(key);
    }

    LyricResult? result = await _fetchDirect(tune);
    result ??= await fetchSearch(tune.title, tune.artist);

    if (result != null) {
      await _repository.save(key, result);
    }

    return result;
  }

  Future<LyricResult?> _fetchDirect(Tune tune) async {
    final uri = Uri.parse(
      '$_base/get'
      '?track_name=${Uri.encodeComponent(_parseTitle(tune.title))}'
      '&artist_name=${Uri.encodeComponent(tune.artist)}'
      '&album_name=${Uri.encodeComponent(tune.album)}'
      '&duration=${tune.duration.inSeconds}',
    );

    final res = await _client.get(uri);

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      return _parseResponse(json);
    } else {
      return null;
    }
  }

  Future<LyricResult?> fetchSearch(String title, String artist) async {
    final uri = Uri.parse(
      '$_base/search'
      '?track_name=${Uri.encodeComponent(_parseTitle(title))}'
      '&artist_name=${Uri.encodeComponent(artist)}',
    );

    final res = await _client.get(uri);

    if (res.statusCode == 200) {
      final list = jsonDecode(res.body) as List;
      if (list.isEmpty) return null;
      return _parseResponse(list.first as Map<String, dynamic>);
    } else {
      return null;
    }
  }

  Future<LyricResult?> reloadLyrics(Tune tune) async {
    final key = tune.songId.toString();
    await _repository.delete(key);
    return fetchLyrics(tune);
  }

  Future<LyricResult?> reloadLyricsManual(
    Tune tune,
    String title,
    String artist,
  ) async {
    final key = tune.songId.toString();
    await _repository.delete(key);
    final result = await fetchSearch(title, artist);
    if (result != null) await _repository.save(key, result);
    return result;
  }

  LyricResult _parseResponse(Map<String, dynamic> json) {
    final syncedRaw = json['syncedLyrics'] as String?;
    final plain = json['plainLyrics'] as String?;
    final instrumental = json['instrumental'] == true;

    return LyricResult(
      synced: syncedRaw != null ? _parseLrc(syncedRaw) : [],
      plain: plain,
      instrumental: instrumental,
    );
  }

  List<LyricLine> _parseLrc(String raw) {
    final regex = RegExp(r'\[(\d+):(\d+)(?:\.(\d+))?\]\s*(.*)');
    final lines = <LyricLine>[];

    for (final match in regex.allMatches(raw)) {
      final min = int.parse(match.group(1)!);
      final sec = int.parse(match.group(2)!);

      final fracStr = match.group(3);
      int ms = 0;

      if (fracStr != null) {
        final value = int.tryParse(fracStr) ?? 0;

        ms = switch (fracStr.length) {
          2 => value * 10,
          3 => value,
          1 => value * 100,
          _ => value,
        };
      }

      final text = (match.group(4)?.trim() ?? '').replaceAll(
        RegExp(r'\[.*?\]'),
        '',
      );

      if (text.isEmpty) continue;

      final timestamp = min * 60000 + sec * 1000 + ms;

      lines.add(LyricLine(timestamp: timestamp, text: text));
    }

    lines.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return lines;
  }

  String _parseTitle(String raw) {
    return raw
        .toLowerCase()
        .replaceAll(RegExp(r'\(.*?\)|\[.*?\]'), '')
        .replaceAll(RegExp(r'\b(feat|ft|remix|version|edit)\b.*'), '')
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
