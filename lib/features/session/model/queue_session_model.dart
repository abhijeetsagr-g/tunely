import 'package:just_audio/just_audio.dart';

class QueueSessionModel {
  final List<String> tunePaths;
  final int currentIndex;
  final bool shuffleEnabled;
  final LoopMode repeatMode;
  final Duration position;
  final double speed;

  QueueSessionModel({
    required this.tunePaths,
    required this.currentIndex,
    required this.shuffleEnabled,
    required this.repeatMode,
    required this.position,
    required this.speed,
  });

  Map<String, dynamic> toJson() {
    return {
      'tunePaths': tunePaths,
      'currentIndex': currentIndex,
      'position': position.inMilliseconds,
      'shuffleEnabled': shuffleEnabled,
      'repeatMode': repeatMode.name,
      'speed': speed,
    };
  }

  factory QueueSessionModel.fromJson(Map<String, dynamic> json) {
    return QueueSessionModel(
      tunePaths: List<String>.from(json['tunePaths'] ?? []),
      currentIndex: json['currentIndex'] ?? 0,
      position: Duration(milliseconds: json['position'] ?? 0),
      shuffleEnabled: json['shuffleEnabled'] ?? false,
      repeatMode: LoopMode.values.firstWhere(
        (e) => e.name == json['repeatMode'],
        orElse: () => LoopMode.off,
      ),
      speed: (json['speed'] ?? 1.0).toDouble(),
    );
  }
}
