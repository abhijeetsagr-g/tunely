import 'package:get_it/get_it.dart';
import 'package:hive_ce/hive.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tunely/features/settings/cubit/customization_cubit.dart';
import 'package:tunely/features/settings/service/customization_service.dart';
import 'package:tunely/features/library/cubit/library_cubit.dart';
import 'package:tunely/features/lyrics/cubit/lyrics_cubit.dart';
import 'package:tunely/features/lyrics/service/lyrics_service.dart';
import 'package:tunely/features/settings/cubit/management_cubit.dart';
import 'package:tunely/features/playback/bloc/playback_bloc.dart';
import 'package:tunely/features/search/cubit/search_cubit.dart';
import 'package:tunely/features/session/cubit/session_cubit.dart';
import 'package:tunely/features/sleep_mode/cubit/sleep_mode_cubit.dart';
import 'package:tunely/features/stats/cubit/stats_cubit.dart';
import 'package:tunely/hive_registrar.g.dart';

import 'package:tunely/features/settings/repository/customization_repository.dart';
import 'package:tunely/features/library/repository/library_repository.dart';
import 'package:tunely/features/library/service/library_service.dart';
import 'package:tunely/features/lyrics/model/lyrics_result.dart';
import 'package:tunely/features/lyrics/repository/lyrics_repository.dart';
import 'package:tunely/features/settings/model/management_settings.dart';
import 'package:tunely/features/settings/repository/management_repository.dart';
import 'package:tunely/features/onboarding/repository/onboarding_repository.dart';
import 'package:tunely/features/playback/service/playback_service.dart';
import 'package:tunely/features/search/repository/search_repository.dart';
import 'package:tunely/features/session/repository/session_repository.dart';
import 'package:tunely/features/stats/model/tune_stats.dart';
import 'package:tunely/features/stats/repository/stats_repository.dart';
import 'package:tunely/features/stats/service/stats_service.dart';
import 'package:tunely/shared/service/artist_service.dart';

final sl = GetIt.instance;

abstract class TunelyInjection {
  static Future<void> init({required PlaybackService audioHandler}) async {
    final dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    Hive.registerAdapters();

    // Open Hive Boxes
    final managementBox = await Hive.openBox<ManagementSettings>(
      'management_settings',
    );
    final statsBox = await Hive.openBox<TuneStats>('stats_box');
    final statsMetaBox = await Hive.openBox('stats_meta');
    final lyricsBox = await Hive.openBox<LyricsResult>('lyrics_box');

    // LazySingleton Repos
    sl.registerLazySingleton<OnAudioQuery>(() => OnAudioQuery());

    sl.registerLazySingleton<ManagementRepository>(
      () => ManagementRepository(managementBox),
    );

    sl.registerLazySingleton<LibraryRepository>(() => LibraryRepository());

    sl.registerLazySingleton<StatsRepository>(
      () => StatsRepository(statsBox, statsMetaBox),
    );

    sl.registerLazySingleton<SessionRepository>(() => SessionRepository());
    sl.registerLazySingleton<SearchRepository>(() => SearchRepository());

    sl.registerLazySingleton<LyricsRepository>(
      () => LyricsRepository(box: lyricsBox),
    );

    final customizationRepo = await CustomizationRepository.create();
    sl.registerLazySingleton<CustomizationRepository>(() => customizationRepo);

    final onboardingRepo = await OnboardingRepository.create();
    sl.registerLazySingleton<OnboardingRepository>(() => onboardingRepo);

    // LazySingleton Services
    sl.registerLazySingleton<LibraryService>(
      () => LibraryService(
        sl<OnAudioQuery>(),
        sl<ManagementRepository>(),
        sl<LibraryRepository>(),
      ),
    );
    sl.registerLazySingleton<StatsService>(
      () => StatsService(audioHandler.onTrackChanged, sl<StatsRepository>()),
    );
    sl.registerLazySingleton<LyricsService>(
      () => LyricsService(repository: sl<LyricsRepository>()),
    );
    sl.registerLazySingleton<CustomizationService>(
      () => CustomizationService(
        query: sl<OnAudioQuery>(),
        repo: sl<CustomizationRepository>(),
      ),
    );
    sl.registerLazySingleton<ArtistService>(() => ArtistService());

    // Register Cubits/Bloc
    sl.registerFactory<PlaybackBloc>(
      () => PlaybackBloc(audioHandler, sl<SessionRepository>()),
    );
    sl.registerFactory<ManagementCubit>(
      () => ManagementCubit(sl<ManagementRepository>()),
    );
    sl.registerFactory<SessionCubit>(
      () => SessionCubit(sl<SessionRepository>()),
    );
    sl.registerFactory<StatsCubit>(
      () => StatsCubit(sl<StatsService>(), sl<LibraryCubit>()),
    );
    sl.registerFactory<SearchCubit>(() => SearchCubit(sl<SearchRepository>()));
    sl.registerFactory<LyricsCubit>(
      () => LyricsCubit(sl<LyricsService>(), sl<PlaybackBloc>()),
    );
    sl.registerFactory<SleepModeCubit>(
      () => SleepModeCubit(playbackService: audioHandler),
    );
    sl.registerFactory<LibraryCubit>(
      () => LibraryCubit(service: sl<LibraryService>()),
    );
    sl.registerFactory<CustomizationCubit>(
      () => CustomizationCubit(sl<CustomizationService>()),
    );
  }
}
