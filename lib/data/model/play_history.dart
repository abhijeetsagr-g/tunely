import 'package:hive_flutter/hive_flutter.dart';

part 'play_history.g.dart';

@HiveType(typeId: 0)
class PlayHistory extends HiveObject {
  @HiveField(0)
  late int songId;

  @HiveField(1)
  late String path;

  @HiveField(2)
  late String title;

  @HiveField(3)
  late String artist;

  @HiveField(4)
  late DateTime playedAt;
}
