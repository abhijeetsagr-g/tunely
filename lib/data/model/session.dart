import 'package:hive_flutter/hive_flutter.dart';
part 'session.g.dart';

@HiveType(typeId: 1)
class Session extends HiveObject {
  @HiveField(0)
  late String currentPath;

  @HiveField(1)
  late int positionMs;

  @HiveField(2)
  late List<String> queuePaths;
}
