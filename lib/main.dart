import 'package:audio_service/audio_service.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_ce/hive.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tunely/features/library/cubit/library_cubit.dart';
import 'package:tunely/features/library/repository/library_repository.dart';
import 'package:tunely/features/library/service/library_service.dart';
import 'package:tunely/features/music_management/model/management_settings.dart';
import 'package:tunely/features/music_management/repository/management_repository.dart';
import 'package:tunely/features/playback/bloc/playback_bloc.dart';
import 'package:tunely/features/playback/service/playback_service.dart';
import 'package:tunely/features/root/cubit/root_cubit.dart';
import 'package:tunely/features/session/cubit/session_cubit.dart';
import 'package:tunely/features/session/repository/session_repository.dart';
import 'package:tunely/features/stats/cubit/stats_cubit.dart';
import 'package:tunely/features/stats/model/tune_stats.dart';
import 'package:tunely/features/stats/repository/stats_repository.dart';
import 'package:tunely/features/stats/service/stats_service.dart';
import 'package:tunely/hive_registrar.g.dart';
import 'package:tunely/my_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  final dir = await getApplicationDocumentsDirectory();
  Hive.init(dir.path);
  Hive.registerAdapters();

  // Generate audio Services
  final audioHandler = await AudioService.init(
    builder: () => PlaybackService(),
    config: const AudioServiceConfig(
      androidNotificationChannelName: "Tunely Playback",
      androidNotificationChannelId: "com.abhijeetsagr.tunely",
      androidNotificationOngoing: true,
    ),
  );

  // setup management
  final managementBox = await Hive.openBox<ManagementSettings>(
    'management_settings',
  );
  final managementRepo = ManagementRepository(managementBox);

  // setup library
  final audioQuery = OnAudioQuery();
  final LibraryRepository libraryRepository = LibraryRepository();
  final LibraryService libraryService = LibraryService(
    audioQuery,
    managementRepo,
    libraryRepository,
  );

  // // setup stats
  final statsBox = await Hive.openBox<TuneStats>('stats_box');
  final statsRepo = StatsRepository(statsBox);
  final stateService = StatsService(audioHandler.onTrackChanged, statsRepo);

  // //  setup session
  final sessionRepo = SessionRepository();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => RootCubit()),
        BlocProvider(create: (context) => PlaybackBloc(audioHandler)),
        BlocProvider(create: (context) => SessionCubit(sessionRepo)),
        BlocProvider(
          create: (context) => LibraryCubit(service: libraryService),
        ),
        BlocProvider(create: (context) => StatsCubit(stateService)),
      ],
      child: MyApp(),
    ),
  );
}
