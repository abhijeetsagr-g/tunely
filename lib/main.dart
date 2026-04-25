import 'package:audio_service/audio_service.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_ce/hive.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tunely/features/customization/cubit/customization_cubit.dart';
import 'package:tunely/features/customization/repository/customization_repository.dart';
import 'package:tunely/features/customization/service/customization_service.dart';
import 'package:tunely/features/library/cubit/library_cubit.dart';
import 'package:tunely/features/library/repository/library_repository.dart';
import 'package:tunely/features/library/service/library_service.dart';
import 'package:tunely/features/lyrics/cubit/lyrics_cubit.dart';
import 'package:tunely/features/lyrics/model/lyrics_result.dart';
import 'package:tunely/features/lyrics/repository/lyrics_repository.dart';
import 'package:tunely/features/lyrics/service/lyrics_service.dart';
import 'package:tunely/features/music_management/cubit/music_manager_cubit.dart';
import 'package:tunely/features/music_management/model/management_settings.dart';
import 'package:tunely/features/music_management/repository/management_repository.dart';
import 'package:tunely/features/playback/bloc/playback_bloc.dart';
import 'package:tunely/features/playback/service/playback_service.dart';
import 'package:tunely/features/root/cubit/root_cubit.dart';
import 'package:tunely/features/search/cubit/search_cubit.dart';
import 'package:tunely/features/session/cubit/session_cubit.dart';
import 'package:tunely/features/session/repository/session_repository.dart';
import 'package:tunely/features/sleep_mode/cubit/sleep_mode_cubit.dart';
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

  // setup lyrics
  final lyricsBox = await Hive.openBox<LyricsResult>('lyrics_box');
  final lyricsRepo = LyricsRepository(box: lyricsBox);
  final lyricsService = LyricsService(repository: lyricsRepo);

  // setup customization
  final customizationRepo = await CustomizationRepository.create();
  final customizationService = CustomizationService(
    query: audioQuery,
    repo: customizationRepo,
  );

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => RootCubit()),
        BlocProvider(create: (context) => ManagementCubit(managementRepo)),
        BlocProvider(create: (context) => PlaybackBloc(audioHandler)),
        BlocProvider(create: (context) => SessionCubit(sessionRepo)),
        BlocProvider(create: (context) => StatsCubit(stateService)),
        BlocProvider(create: (context) => SearchCubit()),
        BlocProvider(create: (context) => LyricsCubit(lyricsService)),
        BlocProvider(
          create: (context) => SleepModeCubit(playbackService: audioHandler),
        ),

        BlocProvider(
          create: (context) => LibraryCubit(service: libraryService),
        ),
        BlocProvider(
          create: (context) => CustomizationCubit(customizationService),
        ),
      ],
      child: MyApp(),
    ),
  );
}
