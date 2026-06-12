import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tunely/features/search/model/recent_item.dart';

class SearchRepository {
  static const _key = 'recent_searches';

  Future<void> saveRecentItems(List<RecentItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final data = items.map((e) => _toJson(e)).toList();
    await prefs.setString(_key, jsonEncode(data));
  }

  Future<List<RecentItemData>> loadRecentItems() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    if (json == null) return [];

    final list = jsonDecode(json) as List;
    return list
        .map((e) => _fromJson(e as Map<String, dynamic>))
        .whereType<RecentItemData>()
        .toList();
  }

  Future<void> clearRecentItems() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  Map<String, dynamic> _toJson(RecentItem item) {
    return switch (item) {
      RecentSongItem s => {
        'type': 'song',
        'title': s.title,
        'subtitle': s.subtitle,
        'songId': s.tune.songId,
      },
      RecentAlbumItem a => {
        'type': 'album',
        'title': a.title,
        'subtitle': a.subtitle,
        'albumId': a.album.id,
      },
      RecentArtistItem a => {
        'type': 'artist',
        'title': a.title,
        'subtitle': a.subtitle,
        'artistId': a.artist.artistId,
      },
    };
  }

  RecentItemData? _fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    if (type == null) return null;

    return RecentItemData(
      type: type,
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String?,
      songId: json['songId'] as int?,
      albumId: json['albumId'] as int?,
      artistId: json['artistId'] as int?,
    );
  }
}

class RecentItemData {
  final String type;
  final String title;
  final String? subtitle;
  final int? songId;
  final int? albumId;
  final int? artistId;

  const RecentItemData({
    required this.type,
    required this.title,
    this.subtitle,
    this.songId,
    this.albumId,
    this.artistId,
  });
}
