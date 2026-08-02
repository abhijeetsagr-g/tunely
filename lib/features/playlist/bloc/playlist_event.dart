part of 'playlist_bloc.dart';

sealed class PlaylistEvent {}

class LoadPlaylistsEvent extends PlaylistEvent {}

class CreatePlaylistEvent extends PlaylistEvent {
  final String name;
  final String? desc;
  final List<int>? songIds;

  CreatePlaylistEvent({required this.name, this.desc, this.songIds});
}

class RenamePlaylistEvent extends PlaylistEvent {
  final int playlistId;
  final String newName;

  RenamePlaylistEvent({required this.playlistId, required this.newName});
}

class DeletePlaylistEvent extends PlaylistEvent {
  final int playlistId;

  DeletePlaylistEvent({required this.playlistId});
}

class LoadSongsEvent extends PlaylistEvent {
  final int playlistId;
  final ManagementSettings settings;

  LoadSongsEvent({required this.playlistId, required this.settings});
}

class RemoveSongEvent extends PlaylistEvent {
  final int playlistId;
  final int songId;

  RemoveSongEvent({required this.playlistId, required this.songId});
}

class AddSongsEvent extends PlaylistEvent {
  final int playlistId;
  final List<int> songIds;

  AddSongsEvent({required this.playlistId, required this.songIds});
}
