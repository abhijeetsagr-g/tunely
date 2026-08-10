# Refactor Tracker

> Goal: make adding features and fixing bugs faster. Behavior-preserving pass — the app must keep working after every phase.
>
> Branch: `develop` (main stays releasable). Every phase is independent and revertible.

---

## Phase A — Foundations (done)

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

## Phase B — Cleanup (done)

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

### B2. Fix feature naming / structure

- [x] Merge `music_management` + `customization` → `features/settings`
  - [x] Cubits: `customization_cubit.dart`, `music_manager_cubit.dart`→`management_cubit.dart`
  - [x] Repos: `customization_repository.dart`, `management_repository.dart`
  - [x] Service: `customization_service.dart`; Model: `management_settings.dart`(+`.g.dart`)
  - [x] `theme_picker.dart` moved from `shared/widget` → `settings/widgets`
- [x] Rename `root` → `shell` (dropped the `ui/` layer)
  - [x] `root_screen.dart` → `shell_screen.dart`, class `RootScreen` → `ShellScreen`
  - [x] `view/home`, `view/splash`, `view/widget/bottom_nav` nested under `shell/view/`
- [x] Delete dead `RootCubit`/`RootState` (registered in DI but never consumed)
- [x] Delete empty vestigial `lib/ui/`
- [x] Verify: `flutter analyze` clean

## Phase C — Feature-wise audit

Go through each feature one at a time: check `state`/`bloc`, `repository`, `service`, `ui/`. Fix inconsistencies, then add tests for that feature before moving on.

Checklist per feature:

- [ ] State: clean, minimal, correct transitions; no dead fields
- [ ] Repository: consistent pattern (owns a data source), no logic leaks
- [ ] Service: single responsibility; no duplication with other features
- [ ] UI: reads via BlocProvider (no `sl<>` in widgets), no hand-rolled wiring
- [ ] Tests: `bloc_test`/`mocktail` for state transitions + pure logic
- [ ] `flutter analyze` + `flutter test` green

- [ ] `features/playlist`
- [ ] `features/playback`
- [ ] `features/onboarding`
- [x] `features/search`

- [x] `features/lyrics`
- [x] `features/library`
- [x] `features/sleep_mode`
- [x] `features/session`
- [x] `features/shell`
- [x] `features/stats`
- [x] `features/settings`

### Session audit notes (done)

- [x] Hardened `SessionRepository.load()` — corrupt JSON now returns `null` instead of crashing splash
- [x] Clamped `startIndex` in `PlaybackService.playQueue()` — restores can no longer OOB-crash when saved tunes were deleted from device
- [x] **Deleted `SessionCubit`** — it was a redundant copy of the session: PlaybackBloc already persists to the repo and holds the live session in state. Splash now reads `SessionRepository` directly (provided via `RepositoryProvider.value`); continue-listening card reads `PlaybackBloc.currentItem` only (the `_restoreSession` tap path + `LibraryCubit` fallback were dead after splash-restore, so they were removed). Dead `save()`/`clear()` went away with it
- [ ] Deferred (D2): `QueueSessionModel` couples persistence to `just_audio` `LoopMode` enum

### Stats audit notes (done)

- [x] Decoupled `StatsCubit.load` from splash — cubit now listens to `LibraryCubit` (also fixes stale lists after rescan)
- [x] **Bugfix:** `StatsCubit` is a lazy provider → missed the initial `LibraryLoaded` → top songs never loaded/updated. Now checks current library state in constructor (belt + stream suspenders)
- [x] **Bugfix (systemic):** all cubits were `registerFactory` → `sl<Cubit>()` returned a *fresh* instance per call, so cubit-to-cubit DI deps detached from the widget tree (`StatsCubit→LibraryCubit` never saw the scan; `LyricsCubit→PlaybackBloc` similarly broken). Converted all cubits to `registerLazySingleton` — `sl<X>()` now always returns the app-scope instance the tree uses
- [x] Split `clearAll()` into specific clears: `clearPlayCounts()`, `clearLikes()`, `clearRecent()` (recent/playCount/likes now independent)
- [x] Removed unused `StatsCubit` import from `splash_view.dart`
- [ ] Deferred: `liked` is dead UI surface (model field + `isLiked`/`toggleLike`/`StatsLoaded.liked`); keep for a future Liked screen
- [ ] Deferred (D2): `StatsService` still takes raw `audioHandler.onTrackChanged` stream; subscription never cancelled (bounded — singleton)
- [ ] Tests to add: `_mostPlayed` order/limit, `_recent` path mapping, repo `toggleLike`/`clearAll`, service play-count dedup + recency

### Settings audit notes (done)

- [x] State/model/service/repo left as-is (reviewed, correct)
- [x] **UI: `settings_screen.dart` → `ListView`** — the `CustomScrollView` used nothing but `SliverToBoxAdapter`/`SliverList` (zero lazy-loading benefit); stripped the sliver wrappers from `artist_delimiter_widget`, `cache_rescan_buttons`, `daily_mix_size_slider`, `min_song_dur_slider`, `about_widget`
- [x] About cards updated (`Created By`/`Special Thanks`); `popUpNotifer` import added, dead `url_launcher` import removed
- [x] `flutter analyze` clean

### Search audit notes (done)

- [x] View verified — slivers are legitimate here (`SliverAppBar` + lazy `SliverList`/`SliverGrid`); `SongTile.onTap` is additive (tap records recent *and* plays via `PlayQueueEvent`), so recents/search taps play correctly
- [x] **Deleted dead code**: `shared/widget/content_view.dart` + `features/search/helper/search_tunes.dart` (`SearchFunctions` — its only consumer was ContentView; the cubit filters inline). Also cleared the corresponding Backlog items
- [x] **Removed dead `SearchResult.genres`** + the genre filtering in `_runSearch` — computed but never displayed (no genre section/chip)
- [x] **Hardened `SearchRepository.loadRecentItems()`** — corrupt `recent_searches` JSON now returns `[]` instead of crashing splash (matches session-repo hardening)
- [x] `_loadRecentItems` clears before loading → no recents duplication on repeated `setLibrary`
- [x] `addRecentItem` re-emits `SearchIdle` when idle → recents order bumps to front on tap (guarded so it never clears live search results)
- [x] **`SearchCubit` now depends on `LibraryCubit` directly** (constructor dep + `library.stream` subscription + construct-time state check, like StatsCubit). Splash `setLibrary` hand-off removed. On `rescan()` (→ `LibraryLoaded` re-emit) search resets: recents reload against the fresh library (deleted tunes dropped), stale-result/stale-recents-after-rescan fixed. `_setLibrary` is now private + `isClosed`-guarded
- [ ] Deferred: tapping a recent item bumps it but doesn't navigate/play from the *artist/album* variants (they have no default tap); songs play correctly
- [ ] Tests to add: debounce→search transitions, recents cap/dedupe/reorder, repo corrupt-JSON, resolve-missing-library

## Phase D — Stretch (only if A-C land early)

### D1. Split `playback_service.dart` (530 lines)

- [ ] Extract shuffle logic into testable `ShuffleQueue` class
- [ ] Extract missing-song handling into `MissingSongTracker`
- [ ] Verify: playback/shuffle/error-skip unchanged + covered by tests

### D2. Decouple cross-feature dependencies

- [ ] `StatsService` — subscribe via interface/stream provider, not `audioHandler.onTrackChanged` directly
- [ ] `LyricsCubit` — depend on a playback interface, not `PlaybackBloc` directly
- [ ] Verify: stats and lyrics still work

## Backlog — items to fold into per-feature audits

### Terminology: unify `tune` / `song` / `track`

- [ ] Model is `Tune` (`tune.dart`, `TuneParser`, `TuneStats`, `sortTunes`, `totalTunesDurations`)
- [ ] UI says `song` (`song_tile`, `mini_song_tile`, `song_tile_sheet`, `queue_song_tile`, `song_info`, `song_action_row`, `min_song_dur_slider`)
- [ ] Audio layer says `track` (`onTrackChanged`)
- [ ] App is Tunely + model is `Tune` → standardize on `tune` (mechanical, ~15 files)

### Library split-brain

- [ ] `library/ui/widget/{albums,artists,playlists,all_songs}_tab.dart` are the tab surfaces
- [ ] Real screens live in `library/ui/view/{album,artist}/` (album_view, artist_view)
- [ ] `PlaylistsTab` is a stub ("I will add this feature soon") while `features/playlist/` has a full `PlaylistBloc` + `playlist_view` used from cards/sheets. Dead tab + orphaned-but-real feature.

### File-level nits

- [ ] Delete dead `shared/widget/content_view.dart` (ContentView referenced nowhere)
- [ ] `recommeded_albums.dart` typo → `recommended_albums.dart`
- [ ] `my_search_bar.dart` → `search_bar.dart`
- [ ] `fur_artist_name.dart`/`fur_duration.dart` → collapse into `core/utils/formatters.dart`
- [ ] `total_song_dur.dart` → `format_total_duration.dart` (avoid clash with `total_dur.dart`)
- [ ] Route args scattered: `AlbumViewParams` (`core/config/app_params.dart`) + `*SettingsArguments` (`core/utils/settings_arguments.dart`) → consolidate into `core/const/` (or per-feature)
- [ ] `core/const` has 4 overlapping router files (`app_route`, `app_router`, `app_page_router`, `app_const`) → consolidate
- [ ] `queue_widget.dart` is really a list → `queue_list.dart`
- [ ] `search_tunes.dart` `SearchFunctions` util-class → top-level functions
- [ ] `shared/service/artist_service.dart` is library domain logic → `features/library/service/` + fix its `RepositoryProvider` registration in `main.dart`
- [ ] `shell` still nests `view/home` (no own cubit yet) — extract `features/home` once it gains its own state
- [ ] `ManagementCubit`/`CustomizationCubit`/`ManagementSettings` class names — revisit during `settings` audit

## Progress notes

- B2 done: `music_management`+`customization` → `settings`; `root` → `shell`; dead `RootCubit` deleted; `analyze` clean.
