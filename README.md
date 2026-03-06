# Tunely 🎵

An offline music player for Android built with Flutter. Tunely scans your device library and lets you browse, play, and manage your music — no internet required.

> Currently in active development. Beta release targeting April 2025.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter (Dart) |
| State Management | BLoC / flutter_bloc |
| Audio Playback | just_audio |
| Background Audio | audio_service |
| Media Scanning | on_audio_query |

---

## Architecture

Tunely follows a layered architecture with a clear separation between services, BLoCs, and UI.

### Services

**`PlaybackService`** — extends `BaseAudioHandler` with `QueueHandler` and `SeekHandler`. Owns the `just_audio` player instance and exposes streams for playback state, position, duration, and sequence changes. All audio operations go through here.

**`AudioQueryService`** — wraps `on_audio_query`. Handles device permission checks and exposes methods to scan songs, albums, artists, genres, and playlists.

### BLoCs

**`PlaybackBloc`** — subscribes to `PlaybackService` streams and converts them into state. Owns:
- `List<Tune> tunes` — full device library
- `List<Tune> queue` — active playback queue (reflects shuffle order via `effectiveSequence`)
- `currentSong`, `isPlaying`, `pos`, `dur`, `isShuffleMode`, `repeatMode`, `hasNext`, `hasPrev`

**`AudioBloc`** — owns raw `on_audio_query` models. Handles library scanning and exposes albums, artists, genres, and playlists to the UI.

### Data Model

**`Tune`** — custom model that replaces `SongModel` as the single UI source of truth. Converts to/from `MediaItem` via `toMediaItem()` and `Tune.fromSongModel()`. Necessary because `SongModel` cannot be manually constructed.

### Key Design Decisions

- `PlaybackService` owns the internal queue — BLoC only listens via streams
- `AudioSource` tags store `MediaItem` for queue lookup
- Queue order uses `effectiveSequence` (not `sequence`) to correctly reflect shuffle state
- `SongLoaded` is dispatched from `SplashView` after `AudioBloc` finishes scanning
- `Optional<T>` wrapper used in `copyWith` for nullable `currentSong`
- `AudioBloc` stores raw `SongModel`; conversion to `Tune` happens in `PlaybackBloc`

---

## Data Flow

```
SplashView
  └── dispatches GetAllSongs + GetAlbums
        └── AudioBloc scans device via AudioQueryService
              └── dispatches SongLoaded → PlaybackBloc stores List<Tune>

User taps song
  └── PlaySong(index, tunes) → PlaybackBloc
        └── PlaybackService.playQueue() → just_audio
              └── sequenceStateStream fires → SequenceChange
                    └── queue, currentSong, hasNext, hasPrev updated in state
```

---

## Project Structure

```
lib/
├── data/
│   └── model/
│       └── tune.dart
├── logic/
│   ├── bloc/
│   │   ├── audio_query/
│   │   │   ├── audio_bloc.dart
│   │   │   ├── audio_event.dart
│   │   │   └── audio_state.dart
│   │   └── playback/
│   │       ├── playback_bloc.dart
│   │       ├── playback_event.dart
│   │       └── playback_state.dart
│   └── service/
│       ├── audio_query_service.dart
│       └── playback_service.dart
└── ui/
    ├── splash/
    ├── home/
    │   └── widget/
    │       └── album_card.dart
    └── player/
        └── widget/
            ├── album_art.dart
            ├── control_buttons.dart
            ├── seek_bar.dart
            └── song_info.dart
```

---

## Roadmap

| Phase | Description | Status | Target |
|---|---|---|---|
| 1 | Core Playback Service | ✅ Complete | — |
| 2 | Library Scanning | ✅ Complete | — |
| 3 | BLoC Setup + PlayerView | ✅ Complete | — |
| 4 | MVP UI + Beta Play Store | 🔨 In Progress | April 15 |
| 5 | Queue Management | ⬜ Planned | April 30 |
| 6 | Full Release | ⬜ Planned | May 20 |

---

## Features (Current)

- Scans device library on launch
- Browse songs and albums
- Full playback controls — play, pause, next, prev
- Seek bar with position + duration
- Shuffle mode (reflects correct queue order)
- Repeat modes — none, repeat all, repeat one
- Album artwork display
- Background audio via `audio_service`

---

## Getting Started

### Prerequisites
- Flutter SDK
- Android device or emulator (API 21+)
- Storage permission granted on first launch

### Run

```bash
flutter pub get
flutter run
```

---

## License

MIT