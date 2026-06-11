# Tunely — TODO

---

## 🐛 Bugs

### B-03 · Queue does not show songs before the current song
Songs played before the current position are missing from the queue screen entirely.

- **Likely cause:** Queue list is being sliced from `currentIndex` onward
  before being passed to the UI, discarding history.
- **Fix:** Pass the full queue to the screen. Render songs before
  `currentIndex` as grayed out (reduced opacity). Do not slice — let the UI
  handle the visual distinction.

---

## 🎨 UI Rebuilds

### UI-01 · Library

**Why:**
- On the Songs and Artists tabs, scrolling down and then back up leaves the
  first list item clipped behind the filter row instead of returning flush
  to the top.
- On the Albums grid, the last row of items is fully obscured by the
  mini-player with no bottom clearance.

**How it should look:**

| Area | Behaviour |
|---|---|
| Filter row | Collapses into a compact/smaller bar as the user scrolls down; re-expands on scroll up |
| Songs / Artists list | Scroll position correctly resets; first item always clears the (possibly collapsed) filter bar |
| Albums grid | Bottom padding auto-calculated to equal the mini-player height so the last row is always fully visible |

**Implementation notes:**
- Use a `SliverAppBar` (or equivalent collapsing header) for the filter row
  with `floating: true` and a reduced `collapsedHeight`.
- Inject `MediaQuery`-aware bottom padding into the grid/list's
  `padding.bottom` tied to the mini-player's rendered height.

---

### UI-02 · Home

**Why:**
- Recently Played updates too frequently, making the top of the screen feel
  noisy and unstable.
- The "Show More" affordance for Albums/Songs had no plays to justify its
  presence.
- Song card color extraction has a visible ~1-frame lag during auto-scroll.
- `CurrentPlayingCard` was redundant given the persistent mini-player.

**What's being removed:**
- Recently Played horizontal list
- "Show More Albums / Songs" section
- `CurrentPlayingCard`

**How it should look:**

```
[ Greeting / App bar ]
─────────────────────
Daily Mix            → see all
  ┌─────────────────────────┐
  │ 🎵  Song Title          │
  │     Artist · Album art  │
  ├─────────────────────────┤
  │ 🎵  Song Title          │
  │     Artist · Album art  │
  ├─────────────────────────┤
  │  ... (5 songs total) ...│
  ├─────────────────────────┤
  │   Check all of Daily Mix│  ← tappable footer row
  └─────────────────────────┘
─────────────────────
Albums               → see all
  [ horizontal album grid ]
```

**Daily Mix specifics:**
- 15 songs total in the mix (renamed from "Recommended Songs").
- Home shows the first 5 as a vertical list (album art left, song title +
  artist right).
- A "Check all of Daily Mix" row at the bottom navigates to the full 15-song
  list.

**Color extraction fix:**
- Pre-extract palette colors when the mix is first built, not on card render.
- Store extracted colors alongside the song data so cards mount with the
  correct color immediately, eliminating the per-card extraction delay.

---

### UI-03 · Search

**Why:**
- Empty state (before typing) showed nothing, feeling broken.
- Filter chips could be clearer about which category is active.

**How it should look:**

_Before typing (empty state):_
- Show a **Recent Searches** list (tappable to re-run).
- Clear-all affordance at the top right of the list.

_While typing (results state):_
- Filter chips: **All · Songs · Artists · Albums**
- When a filter chip is tapped, its section expands to show full results;
  all other sections collapse entirely.
- Tapping the active chip again resets to "All" (all sections visible in
  summary form).

---

### UI-04 · Player

**Why:**
- Spacing between controls felt inconsistent across device sizes because of
  hardcoded values.
- No animation made the screen feel static.

**How it should look:**

_Animations:_
- **Song change:** Album art slides out in the swipe direction and the
  incoming art slides in from the opposite side.
- **Play / Pause:** Album art scales up slightly on play, scales back down
  on pause (subtle, ~1.05× scale factor).
- Both animations should respect `MediaQuery.disableAnimations` for
  accessibility.

_Spacing:_
- Layout is currently undecided between a single adaptive layout vs.
  breakpoint-based layouts. **Revisit after seeing the new design on a
  physical device.** In the interim, replace all hardcoded pixel gaps with
  `Spacer` / `Expanded` widgets so the layout at least scales
  proportionally to screen height.

---

### UI-05 · Lyrics

**Why:**
- No way to look up lyrics for a song other than the currently playing one.
- No way to supply a local `.lrc` file when the API returns nothing.
- Fetch only triggered when the screen is opened with a new current song —
  rapid song changes while the screen is open can cause stale or missed
  fetches.

**How it should look:**

_App bar:_
```
[ Lyrics ]   [ 🔍 ]   [ ⋯ ]
```
- **Search icon (🔍):** Opens a song picker (reuse the library song list);
  selecting a song fetches and displays its lyrics without affecting playback.
- **Overflow menu (⋯):** Contains "Import .lrc file" — opens the system file
  picker filtered to `.lrc`; imported lyrics are saved and override any
  API-fetched result for that song.

_Fetch reliability fix:_
- Move the fetch trigger out of the screen's `initState` / `didChangeDependencies`
  and into a dedicated lyrics cubit/bloc that listens to the playback stream
  independently.
- Debounce rapid song changes (e.g. 400 ms) so only the final song in a
  quick-skip sequence triggers a network call.
- Maintain a per-song lyrics cache so revisiting a song within a session
  never re-fetches.

---

### UI-06 · Artist Detail / ArtistList

**Why:**
- All list views across the app look identical — no visual differentiation
  between context (songs vs. artists vs. albums).

**How it should look:**

- Songs grouped by album, with an album header row separating each group
  (album title + year).
- Color scheme extracted from the **artist's cover art** and applied to the
  screen (background tint, header gradient, chip/button accent).
- Artist art displayed prominently at the top (hero-style), fading into the
  song list below.

**Implementation notes:**
- Group the song list by `albumId` before rendering; use a `SliverList` with
  sticky album header slivers.
- Run palette extraction on the artist image once and cache the result; pass
  the dominant/muted color down via `InheritedWidget` or a scoped provider.

---

### UI-07 · Album Detail / AlbumList

**Why:**
- Same visual sameness problem as ArtistList.

**How it should look:**

- Color scheme extracted from the **album art** (same extraction pipeline as
  UI-06, scoped to album art instead).
- Default expanded view includes an **artist tabs widget** anchored at the
  bottom of the screen — one tab per artist featured on the album. Tapping a
  tab navigates to that artist's detail screen (UI-06).
- Track list in standard vertical order with track number, title, duration.

**Implementation notes:**
- Artist tabs widget: use a `BottomNavigationBar`-style strip or a
  horizontally scrollable chip row if there are more than 3 featured artists.
- Reuse the same color extraction + caching pattern from UI-06.

---

### UI-08 · Settings

**Why:**
- Currently only exposes Dark / Light / Auto theme mode — no music
  management controls, no maintenance actions, no theming beyond mode.

**How it should look:**

```
Settings
─────────────────────
Appearance
  Theme Mode          → [Light / Dark / Auto]  (existing)
  App Theme           → theme picker (new)

Music
  Artist Delimiter    → text field  e.g. " ; "
  Album Artist Delimiter → text field
  Minimum Song Duration → slider or numeric input (seconds)

Library
  Rescan for Songs    → button (triggers full media-store rescan)

Lyrics
  Reset All Lyrics    → button (clears cached + imported lyrics for all songs)
                        confirmation dialog before executing

─────────────────────
About                 → navigates to About screen
```

**Settings — detail notes:**

_Music Management:_
- **Artist / Album Artist Delimiters:** allow the user to define the
  character(s) used to split multi-artist tags (e.g. `";"`, `" & "`, `"/"`).
  Applied at scan/parse time; changing a delimiter should prompt a rescan.
- **Minimum Song Duration:** songs shorter than this threshold are excluded
  from the library. Default suggested: 60 s. Use a slider (30 s – 300 s) with
  a numeric label, or a plain text field for exact input.

_Rescan for Songs:_
- Re-queries the media store and diffs against the existing library.
- Show a progress indicator or snackbar feedback while running.
- Should not block the UI (run in background isolate or service).

_Reset All Lyrics:_
- Deletes all entries from the lyrics cache (both API-fetched and
  user-imported `.lrc` files).
- Always gated behind a confirmation dialog:
  `"This will remove all saved lyrics. This cannot be undone."`

_App Theme (ThemeMode extension):_
- Opens a theme picker — could be a bottom sheet or a dedicated sub-screen.
- Exact theme options TBD based on available named theme packs.

---

### UI-10 · Playlist UI

**Why:**
- No way to manage playlist contents beyond creation — missing add/remove,
  reorder, and bulk organisation controls.

**How it should look:**

```
[ Playlist Name ]           [ ⋯ ]
─────────────────────
  ≡  Song Title             [ 🗑 ]
     Artist · Duration
  ≡  Song Title             [ 🗑 ]
     Artist · Duration
  ...
─────────────────────
[ + Add Songs ]
```

_Reorder:_ drag handle (`≡`) on the left — long-press or press-and-drag to
reorder. Use Flutter's `ReorderableListView`.

_Delete:_ per-row trash icon. Confirmation only if the playlist would become
empty.

_Add Songs:_ floating or pinned button at the bottom opens a song picker
(multi-select from the full library). Already-added songs shown as checked
and non-selectable.

**Auto-sort buttons** (accessible via the `⋯` overflow menu):

| Action | Behaviour |
|---|---|
| Sort by Title | Alphabetical A → Z |
| Sort by Artist | Alphabetical by artist name |
| Sort by Date Added | Most recently added first |
| Sort by Duration | Shortest → longest |
| Shuffle Order | Randomises current order in-place |

All auto-sort actions are immediately applied to the list and persisted.
No undo — user can re-sort or drag to correct if needed.

---

### UI-11 · Onboarding

**Why:**
- App currently has no onboarding — first launch drops the user straight into
  an empty library with no guidance and no permissions context.

**Flow: 4 steps (paged, swipeable forward / button-driven back)**

```
Step 1 — Welcome
Step 2 — Appearance
Step 3 — Permissions
Step 4 — Scan
```

A step indicator (dots or numbered) is visible throughout. The user cannot
skip Steps 3 or 4 — permissions and scan are required to use the app.

---

**Step 1 — Welcome**
- App icon + name + one-line tagline.
- Single "Get Started" button advances to Step 2.

---

**Step 2 — Appearance**
- Heading: "Choose your theme"
- Three option cards side by side: **Light · Dark · Auto**
- Selected card highlighted (border or checkmark).
- "Next" button — selection saved to prefs immediately so it applies for the
  rest of onboarding and beyond.
- Default pre-selected: Auto.

---

**Step 3 — Permissions**
- Heading: "Allow access to your music"
- Short human-readable explanation of what each permission is for:
  - **Storage / Media:** to read your music files
  - **Notifications:** to show playback controls in the notification shade
- "Grant Permissions" button triggers the system permission dialogs in
  sequence.
- If a permission is denied, show an inline warning with a "Open Settings"
  deep-link so the user can manually grant it.
- "Next" only enabled once storage/media permission is granted (notifications
  can be skipped).

---

**Step 4 — Scan**
- Heading: "Finding your music"
- Subtext: "Tunely is scanning your device for songs."
- Animated progress indicator while scan runs.
- On completion: show song count found  e.g. `"Found 248 songs"`.
- "Go to Library" button appears after scan completes — navigates to the main
  app and marks onboarding as done in prefs (never shown again).
- If 0 songs found: show an empty-state message with a "Rescan" button and a
  note about supported formats.

**Implementation notes:**
- Gate the entire app on an `onboardingComplete` boolean in shared prefs.
- Use a `PageView` with `NeverScrollableScrollPhysics` for the step container
  so only intentional navigation advances the flow.
- Permissions logic should be extracted into a dedicated service reused by
  the Settings rescan flow.

---

### UI-12 · Queue Screen

**Why:**
- Drag to reorder doesn't work — only swipe-to-remove exists.
- Songs before the current position are hidden (see B-03).

**How it should look:**

```
Now Playing
─────────────────────
  [grayed]  Song Title        ← already played
  [grayed]  Song Title        ← already played
  ▶  Song Title               ← current (full opacity, accent highlight)
  ≡  Song Title               ← upcoming
  ≡  Song Title               ← upcoming
  ...
```

- Songs before current: rendered at ~40% opacity, no drag handle, not
  reorderable (they're history).
- Current song: full opacity, accent color left border or highlight,
  not draggable.
- Upcoming songs: full opacity, drag handle (`≡`) on the right,
  `ReorderableListView` so drag-to-reorder works.

**Animations:**
- **Remove (swipe):** existing swipe gesture kept. Animate as
  `Dismissible` sliding out to the side, remaining items close the gap.
- **Reorder:** standard drag lift shadow + snap-into-place on drop.
- **Song advances:** the previously current item fades/dims to grayed
  state; the new current item highlights — driven by the playback stream,
  no manual refresh needed.

**Implementation notes:**
- Split the queue list into two segments at `currentIndex` before rendering:
  `history` (non-reorderable) + `upcoming` (reorderable). Avoids fighting
  `ReorderableListView` over which items can be dragged.
- Reorder changes must update the underlying player queue atomically to avoid
  B-01-style index drift.

---

## 🔮 Deferred / Needs Decision

| ID | Item | Blocker |
|---|---|---|
| D-01 | Player spacing — single adaptive vs. breakpoint layouts | Test new design on physical device first |
| D-02 | Color extraction — move to isolate vs. pre-computation only | Profile on low-end device to decide |