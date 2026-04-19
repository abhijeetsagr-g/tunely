## Goal
- [ ] Organize it correctly
- [ ] Add New features
- [ ] Maintain Checklist


---
x - done with logic
xx - done with testing the logic
xxx - done with implementing UI for the logic 
---

- [xx] Playback services
	- [xx] Notification Integration (Next, Prev, Play, seek)
	- [xx] Show Queue (List of Tunes dynamically)
	- [xx] Handles Shuffle, Repeat Modes, etc
	- [xx] Basic controls
	- [xx] Gapless playback

- [xx] Queue Management
	- [xx] Add To Queue
	- [xx] Play after this 
	- [xx] Remove from Queue
	- [xx] Add a list of tunes to queue
	- [xx] Skip to that queue

- [xx] Stats Management
	- [xx] Most Played Playlist (Unedittable) 
	- [xx] Recently Played Playlist
	- [xx] Liked Playlist

- [xx] Music Management
	- [xx] Exclude Directories
	- [xx] Handle Multi-artist parsing
		- [xx] Delimiters (/ , ; + &)
		- [xx] User Can add more delimiters
	- [xx] Minimum Song Duration: (Default 10s)

- [x] Search lookup
	- [x] Search Songs (Show Album, Playlist, Title, etc)

- [x] Lyrics
	- [ ] Auto load lyrics once, save it locally (fallback to LRCLB)
	- [x] Search Lyrics with Song title and artist
	- [x] Delay/increase sync offset
	- [x] Lyrics offset saved per song
	- [x] Write changes and update locally

- [ ] Playlist Management
	- [ ] Create, Edit Name, remove playlist
	- [ ] Playlist cover :- 4 AlbumArt from first  
	- [ ] Save, Remove, Hide, Sort Tune (custom + other sorts)

--- 

- [ ] Customisation
	- [ ] Extracting colour from album (Togglable)
	- [ ] Choose accent colour or save current dynamic colour
	- [ ] Clean dark/light/system mode
	- [ ] Customise Home Screen (reorder/toggle sections)
	- [ ] Library View options (change top column, etc)

- [ ] Song Metadata
	- [ ] Edit Song's Metadata
	- [ ] Find a minimal way to manage it

- [ ] Etc
	- [ ] Sleep Timer (Notify when ends)
	- [ ] Get Artist Image by Artist Name (Dezeer API, fallback to ArtistImage by AudioQueryWidget)
	- [ ] Backup & Restore (playlists, preferences, lyrics cache — JSON export)
	- [ ] Multi-select actions (bulk add to queue, add to playlist, etc)
	- [x] Sort everywhere: Artist, Album, Title, Genre, Playlist

---


## Done Completely

- [xxx] Queue persistence
  - [xxx] List of songs in queue
  - [xxx] Current playing index
  - [xxx] Playback position (timestamp)
  - [xxx] Shuffle state
  - [xxx] Repeat mode
