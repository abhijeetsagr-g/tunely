import 'package:tunely/shared/model/tune.dart';

Map<int, Duration> totalDurationBy(
  List<Tune> tunes,
  int? Function(Tune tune) keyOf,
) {
  final durations = <int, Duration>{};
  for (final tune in tunes) {
    final id = keyOf(tune);
    if (id == null) continue;
    durations[id] = (durations[id] ?? Duration.zero) + tune.duration;
  }
  return durations;
}
