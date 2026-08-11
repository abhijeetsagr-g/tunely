import 'package:audio_service/audio_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/core/di/injection.dart';
import 'package:tunely/features/playlist/cubit/playlist_cubit.dart';

import 'package:tunely/my_app.dart';

import 'package:tunely/features/settings/cubit/customization_cubit.dart';
import 'package:tunely/features/library/cubit/library_cubit.dart';
import 'package:tunely/features/lyrics/cubit/lyrics_cubit.dart';
import 'package:tunely/features/settings/cubit/management_cubit.dart';
import 'package:tunely/features/onboarding/repository/onboarding_repository.dart';
import 'package:tunely/features/playback/bloc/playback_bloc.dart';
import 'package:tunely/features/playback/service/playback_service.dart';
import 'package:tunely/features/search/cubit/search_cubit.dart';
import 'package:tunely/features/session/repository/session_repository.dart';
import 'package:tunely/features/sleep_mode/cubit/sleep_mode_cubit.dart';
import 'package:tunely/features/stats/cubit/stats_cubit.dart';
import 'package:tunely/shared/service/artist_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Keep it portrait
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Generate audio Services
  final audioHandler = await AudioService.init(
    builder: () => PlaybackService(),
    config: const AudioServiceConfig(
      androidNotificationChannelName: "Tunely Playback",
      androidNotificationChannelId: "com.abhijeetsagr.tunely",
      androidNotificationOngoing: true,
    ),
  );

  await TunelyInjection.init(audioHandler: audioHandler);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<ManagementCubit>()),
        BlocProvider(create: (_) => sl<PlaybackBloc>()),
        BlocProvider(create: (_) => sl<StatsCubit>()),
        BlocProvider(create: (_) => sl<SearchCubit>()),
        BlocProvider(create: (_) => sl<LyricsCubit>()),
        BlocProvider(create: (_) => sl<SleepModeCubit>()),
        BlocProvider(create: (_) => sl<LibraryCubit>()),
        BlocProvider(create: (_) => sl<CustomizationCubit>()),
        BlocProvider(create: (_) => sl<PlaylistCubit>()),

        RepositoryProvider.value(value: sl<ArtistService>()),
        RepositoryProvider.value(value: sl<OnboardingRepository>()),
        RepositoryProvider.value(value: sl<SessionRepository>()),
      ],
      child: MyApp(),
    ),
  );
}
