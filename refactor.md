# Refactor Tracker

> Goal: make adding features and fixing bugs faster. Behavior-preserving pass — the app must keep working after every phase.
>
> Branch: `develop` (main stays releasable). Every phase is independent and revertible.

---

## Phase A — Foundations

### A1. Add `get_it` + feature injection modules

- [x] Add `get_it` to `pubspec.yaml`
- [x] Create `lib/core/di/injection.dart` — single `TunelyInjection.init()` (single-file style)
- [x] Slim `main.dart`: only `WidgetsFlutterBinding`, Hive init, `AudioService.init`, `TunelyInjection.init()`, thin `MultiBlocProvider`
- [x] Delete hand-wired constructors from `main.dart`
- [x] Verify: app boots, library scans, playback works

### A2. Move session persistence out of `MyApp`

- [x] Delete the two session-saving `BlocListener`s from `my_app.dart`
- [x] Missing-song sync — kept a single `BlocListener` in `MyApp` (needs app-lifetime scope + both cubits)
- [x] Inject `SessionRepository` into `PlaybackBloc`
- [x] Add persistence to `PlaybackBloc` (queue/index/shuffle/repeat changed + pause position + speed + missing-song)
- [x] `my_app.dart` becomes a thin `MaterialApp`
- [x] Verify: queue/position/shuffle survive restart

## Phase B — Cleanup

### B1. Tidy `core/utlis` → `core/utils` (fix `praser`/`avater` typos)

- [x] Rename dir to `core/utils`
- [x] Move domain helpers into their features:
  - [x] `sort.dart`, `total_dur.dart`, `total_song_dur.dart`, `artist_praser`→`artist_parser`, `tune_praser`→`tune_parser` → `features/library/helper`
  - [x] `search_tunes.dart` → `features/search/helper`
  - [x] `artist_avater`→`artist_avatar` (kept in `shared/widget`)
  - [x] `fur_artist_name.dart`, `fur_duration.dart` → kept in `core/utils` (generic, cross-feature)
  - [x] `show_snackbar.dart`, `random_texts.dart`, `settings_arguments.dart` → kept in `core/utils`
- [x] Grep-confirm zero references to `core/utlis` / old typos
- [x] Verify: `flutter analyze` clean

## Phase C — Tests

### C1. Pure-logic tests

- [ ] `test/core/utils/sort_test.dart` (sortTunes/sortAlbums/sortArtists: asc/desc, null track, case-insensitive)
- [ ] `test/features/library/tune_parser_test.dart` (parser + daily-mix date-seed determinism)
- [ ] `test/features/playback/playback_bloc_test.dart` (`bloc_test` + `mocktail`, mock `PlaybackService`)
- [ ] `test/features/session/session_repository_test.dart` (mocked `SharedPreferences`)
- [ ] Verify: `flutter test` green

## Phase D — Stretch (only if A-C land early)

### D1. Split `playback_service.dart` (530 lines)

- [ ] Extract shuffle logic into testable `ShuffleQueue` class
- [ ] Extract missing-song handling into `MissingSongTracker`
- [ ] Verify: playback/shuffle/error-skip unchanged + covered by tests

### D2. Decouple cross-feature dependencies

- [ ] `StatsService` — subscribe via interface/stream provider, not `audioHandler.onTrackChanged` directly
- [ ] `LyricsCubit` — depend on a playback interface, not `PlaybackBloc` directly
- [ ] Verify: stats and lyrics still work

---

## Out of scope (for later)

- [ ] Relocate `lib/hive_registrar.g.dart` into models/generated dir
- [ ] Any further layer restructuring

## Progress notes
<!-- append notes as you go -->
