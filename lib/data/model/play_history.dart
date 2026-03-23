import 'package:isar/isar.dart';
part 'play_history.g.dart';

@collection
class PlayHistory {
  Id id = Isar.autoIncrement;
  late int songId;
  late String path;
  late String title;
  late String artist;
  late DateTime playedAt;
}
