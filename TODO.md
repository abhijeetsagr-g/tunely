# Tunely — TODO

## Bugs

- [ ] **B-03 — Queue hides songs before current position** — queue list slices from `currentIndex` onward. Pass full queue & gray out history.

## UI Rebuilds

### UI-01 · Library
- [ ] Filter row collapses on scroll (use `SliverAppBar`)
- [ ] Albums grid bottom padding accounts for mini-player height
- [ ] Scroll position resets correctly so first item clears the filter bar

### UI-02 · Home
- [ ] Remove Recently Played horizontal list
- [ ] Remove "Show More Albums / Songs"
- [ ] Remove `CurrentPlayingCard`
- [ ] Show Daily Mix (15 songs, first 5 as vertical list)
- [ ] Pre-extract palette colors on mix build, cache alongside song data

### UI-05 · Lyrics
- [ ] Search icon opens song picker to fetch lyrics without affecting playback
- [ ] Overflow menu → "Import .lrc file"
- [ ] Move fetch trigger into dedicated cubit listening to playback stream
- [ ] Debounce rapid song changes (400ms)
- [ ] Per-song in-session cache

### UI-06 · Artist Detail
- [ ] Group songs by album with sticky headers
- [ ] Extract & apply color scheme from artist cover art
- [ ] Hero-style artist art at top

### UI-07 · Album Detail
- [ ] Extract & apply color scheme from album art
- [ ] Artist tabs widget at bottom (one tab per featured artist)


### UI-10 · Playlist UI
- [ ] Add songs (multi-select from library)
- [ ] Remove songs (per-row trash icon)
- [ ] Reorder via drag handle (use `ReorderableListView`)
- [ ] Auto-sort buttons (title, artist, date added, duration, shuffle)

### UI-11 · Onboarding
- [ ] Step 1 — Welcome (app icon + name + "Get Started")
- [ ] Step 2 — Appearance (Light/Dark/Auto picker)
- [ ] Step 3 — Permissions (storage + notifications with deep-link fallback)
- [ ] Step 4 — Scan (progress + result summary)
- [ ] Gate app behind `onboardingComplete` in prefs

### UI-08 · Settings
- [x] App Theme picker
- [x] Artist / Album Artist delimiter text fields
- [x] Minimum Song Duration slider
- [x] Rescan button
- [x] Reset All Lyrics button (with confirmation)


### UI-04 · Player
- [x] Song change: album art slides in/out (respects swipe direction)
- [x] Play/Pause: subtle scale animation on album art (~1.05×)
- [ ] Replace hardcoded pixel gaps with `Spacer`/`Expanded`


### UI-12 · Queue Screen
- [x] Reorderable upcoming section
- [x] Swipe-to-remove kept, animate as `Dismissible`



## Deferred

| ID | Item | Blocker |
|---|---|---|
| D-01 | Adaptive vs. breakpoint player layout | Test on physical device |
| D-02 | Color extraction — isolate vs. pre-compute | Profile on low-end device |

--- 

## Working on Right now
