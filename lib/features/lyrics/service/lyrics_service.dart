import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:tunely/features/lyrics/model/lyrics_line.dart';
import 'package:tunely/features/lyrics/model/lyrics_result.dart';
import 'package:tunely/features/lyrics/repository/lyrics_repository.dart';
import 'package:tunely/shared/model/tune.dart';

class LyricsService {
  final LyricsRepository _repository;
  final _base = 'https://lrclib.net/api';

  LyricsService({required LyricsRepository repository})
    : _repository = repository;

  // fetch songs automaticallyy
  Future<LyricsResult?> fetchLyrics(Tune tune) async {
    final key = tune.songId?.toString() ?? tune.path;
    if (_repository.exists(key)) {
      return _repository.get(key);
    }

    LyricsResult? result = await _fetchDirect(tune);
    result ??= await fetchSearch(_parseTitle(tune.title), tune.artist);
    if (result != null) {
      await _repository.save(key, result);
    }
    return result;
  }

  Future<LyricsResult?> fetchSearch(String title, String artist) async {
    final uri = Uri.parse(
      '$_base/search'
      '?track_name=${Uri.encodeComponent(_parseTitle(title))}'
      '&artist_name=${Uri.encodeComponent(artist)}',
    );

    try {
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final list = jsonDecode(res.body) as List;
        if (list.isEmpty) return null;
        return _parseResponse(list.first as Map<String, dynamic>);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<LyricsResult?> reloadLyrics(Tune tune) async {
    final key = tune.songId?.toString() ?? tune.path;

    await _repository.delete(key);
    return fetchLyrics(tune);
  }

  Future<LyricsResult?> reloadLyricsManual(
    Tune tune,
    String title,
    String artist,
  ) async {
    final key = tune.songId?.toString() ?? tune.path;

    await _repository.delete(key);
    final result = await fetchSearch(title, artist);
    if (result != null) await _repository.save(key, result);
    return result;
  }

  Future<LyricsResult?> _fetchDirect(Tune tune) async {
    final uri = Uri.parse(
      '$_base/get'
      '?track_name=${Uri.encodeComponent(_parseTitle(tune.title))}'
      '&artist_name=${Uri.encodeComponent(tune.artist)}'
      '&album_name=${Uri.encodeComponent(tune.album)}'
      '&duration=${tune.duration.inSeconds}',
    );

    try {
      final res = await http.get(uri);
      if (res.statusCode == 200) return _parseResponse(jsonDecode(res.body));
      return null;
    } catch (_) {
      return null;
    }
  }

  // Save offset for a song
  Future<LyricsResult?> saveOffset(Tune tune, int offsetMs) async {
    final key = tune.songId?.toString() ?? tune.path;
    final result = _repository.get(key);
    if (result == null) return null;
    final updated = result.copyWith(offsetMs: offsetMs);
    await _repository.save(key, updated);
    return updated;
  }

  // Edit a single line (text or timestamp) and persist
  Future<LyricsResult?> editLine(
    Tune tune,
    int index,
    LyricsLine updated,
  ) async {
    final key = tune.songId?.toString() ?? tune.path;
    final result = _repository.get(key);
    if (result == null) return null;
    if (index < 0 || index >= result.synced.length) return null;
    result.synced[index].timestamp = updated.timestamp;
    result.synced[index].text = updated.text;
    await _repository.save(key, result);
    return result;
  }

  // Delete a single line and persist
  Future<LyricsResult?> deleteLine(Tune tune, int index) async {
    final key = tune.songId?.toString() ?? tune.path;
    final result = _repository.get(key);
    if (result == null) return null;
    if (index < 0 || index >= result.synced.length) return null;
    result.synced.removeAt(index);
    await _repository.save(key, result);
    return result;
  }

  // Add a new line and persist (re-sorts by timestamp after insert)
  Future<LyricsResult?> addLine(Tune tune, LyricsLine line) async {
    final key = tune.songId?.toString() ?? tune.path;
    final result = _repository.get(key);
    if (result == null) return null;
    result.synced.add(line);
    result.synced.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    await _repository.save(key, result);
    return result;
  }

  // Replace plain lyrics locally
  Future<LyricsResult?> editPlain(Tune tune, String plain) async {
    final key = tune.songId?.toString() ?? tune.path;
    final result = _repository.get(key);
    if (result == null) return null;
    final updated = result.copyWith(plain: plain);
    await _repository.save(key, updated);
    return updated;
  }

  LyricsResult _parseResponse(Map<String, dynamic> json) {
    final syncedRaw = json['syncedLyrics'] as String?;
    final plain = json['plainLyrics'] as String?;
    final instrumental = json['instrumental'] == true;

    return LyricsResult(
      synced: syncedRaw != null ? _parseLrc(syncedRaw) : [],
      plain: plain,
      instrumental: instrumental,
    );
  }

  List<LyricsLine> _parseLrc(String raw) {
    final regex = RegExp(r'\[(\d+):(\d+)(?:\.(\d+))?\]\s*(.*)');
    final lines = <LyricsLine>[];

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
      lines.add(LyricsLine(timestamp: timestamp, text: text));
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
