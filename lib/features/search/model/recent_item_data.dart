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
