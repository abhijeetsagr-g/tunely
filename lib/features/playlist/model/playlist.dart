import 'package:hive_ce/hive_ce.dart';

part 'playlist.g.dart';

@HiveType(typeId: 6)
class Playlist extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String? description;

  @HiveField(2)
  DateTime createdAt;

  @HiveField(3)
  DateTime updatedAt;

  @HiveField(4)
  List<String> songPaths;

  Playlist({
    required this.name,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    this.songPaths = const [],
  });

  Playlist copyWith({
    String? name,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? songPaths,
  }) => Playlist(
    name: name ?? this.name,
    description: description ?? this.description,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    songPaths: songPaths ?? this.songPaths,
  );
}
