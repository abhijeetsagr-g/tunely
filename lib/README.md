## Goal
- [ ] Organize it correctly
- [ ] Add New features
- [ ] Maintain Checklist


---
x - done with logic
xx - done with testing the logic
xxx - done with implementing UI for the logic 

---
- [xx] Stats Management
	- [xxx] Most Played Playlist (Unedittable) 
	- [xxx] Recently Played Playlist
	- [xx] Liked Playlist

- [xx] Music Management
	- [xx] Exclude Directories
	- [xx] Handle Multi-artist parsing
		- [xx] Delimiters (/ , ; + &)
		- [xx] User Can add more delimiters
	- [xx] Minimum Song Duration: (Default 10s)

- [ ] Playlist Management
	- [x] Create, Edit Name, remove playlist
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
	- [x] Get Artist Image by Artist Name (Dezeer API, fallback to ArtistImage by AudioQueryWidget)
	- [d] Backup & Restore (playlists, preferences, lyrics cache — JSON export)
	- [d] Multi-select actions (bulk add to queue, add to playlist, etc)
	- [x] Sort everywhere: Artist, Album, Title, Genre, Playlist

---


## Done Completely
- [xxx] Queue persistence
  - [xxx] List of songs in queue
  - [xxx] Current playing index
  - [xxx] Playback position (timestamp)
  - [xxx] Shuffle state
  - [xxx] Repeat mode

- [xxx] Playback services
	- [xxx] Notification Integration (Next, Prev, Play, seek)
	- [xxx] Show Queue (List of Tunes dynamically)
	- [xxx] Handles Shuffle, Repeat Modes, etc
	- [xxx] Basic controls
	
- [xxx] Queue Management
	- [xxx] Add To Queue
	- [xxx] Play after this 
	- [xxx] Remove from Queue
	- [xxx] Add a list of tunes to queue
	- [xxx] Skip to that queue

- [xxx] Lyrics
	- [xxx] Auto load lyrics once, save it locally (fallback to LRCLB)
	- [xxx] Search Lyrics with Song title and artist
	- [d] Delay/increase sync offset
	- [d] Lyrics offset saved per song
	- [d] Write changes and update locally

- [x] Search lookup
	- [x] Search Songs (Show Album, Playlist, Title, etc)
