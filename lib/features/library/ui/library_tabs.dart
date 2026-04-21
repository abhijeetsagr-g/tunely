part of 'library_view.dart';

class _SongsTab extends StatelessWidget {
  final List<Tune> tunes;
  const _SongsTab({required this.tunes});

  @override
  Widget build(BuildContext context) {
    if (tunes.isEmpty) return const Center(child: Text("No songs found."));
    return ListView.builder(
      itemCount: tunes.length,
      padding: EdgeInsets.only(bottom: 100),
      itemBuilder: (context, index) {
        return SongTile(tunes: tunes, index: index);
      },
    );
  }
}

class _AlbumsTab extends StatelessWidget {
  final List<AlbumModel> albums;
  const _AlbumsTab({required this.albums});

  @override
  Widget build(BuildContext context) {
    if (albums.isEmpty) return const Center(child: Text("No albums found."));
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.78,
      ),
      itemCount: albums.length,
      itemBuilder: (context, index) {
        return AlbumCard(album: albums[index], width: 180);
      },
    );
  }
}

class _ArtistsTab extends StatelessWidget {
  final List<Artist> artists;
  const _ArtistsTab({required this.artists});

  @override
  Widget build(BuildContext context) {
    if (artists.isEmpty) return const Center(child: Text("No artists found."));
    return ListView.builder(
      padding: EdgeInsets.only(bottom: 100),
      itemCount: artists.length,
      itemBuilder: (context, index) {
        final artist = artists[index];
        return ArtistCard(artist: artist);
      },
    );
  }
}

class _GenresTab extends StatelessWidget {
  final List<GenreModel> genres; // adjust if your type differs
  const _GenresTab({required this.genres});

  @override
  Widget build(BuildContext context) {
    if (genres.isEmpty) return const Center(child: Text("No genres found."));
    return ListView.builder(
      itemCount: genres.length,
      itemBuilder: (context, index) {
        final genre = genres[index];
        return ListTile(
          leading: const Icon(Icons.label_outline),
          title: Text(
            genre.genre,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text(
            "${genre.numOfSongs} songs",
            style: Theme.of(context).textTheme.bodySmall,
          ),
          onTap: () {},
        );
      },
    );
  }
}

class _PlaylistsTab extends StatelessWidget {
  const _PlaylistsTab();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const PlaylistView(),
        Positioned(
          bottom: 16 + 80,
          right: 16,
          child: FloatingActionButton(
            onPressed: () {},
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
