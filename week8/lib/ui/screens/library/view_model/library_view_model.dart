import 'package:flutter/material.dart';
import '../../../../data/repositories/songs/song_repository.dart';
import '../../../states/player_state.dart';
import '../../../../model/songs/song.dart';

enum AsyncValueState { loading, error, success }
class AsyncValue<T> {
  final T? data;
  final Object? error;
  final AsyncValueState state;

  AsyncValue.loading()
    : state = AsyncValueState.loading,
      data = null,
      error = null;
  AsyncValue.success(T data)
    : state = AsyncValueState.success,
      this.data = data,
      error = null;
  AsyncValue.error(Object error)
    : state = AsyncValueState.error,
      data = null,
      this.error = error;
}

class LibraryViewModel extends ChangeNotifier {
  final SongRepository songRepository;
  final PlayerState playerState;
  // List<Song>? _songs;
  AsyncValue<List<Song>> songsValue = AsyncValue.loading();

  LibraryViewModel({required this.songRepository, required this.playerState}) {
    playerState.addListener(notifyListeners);

    // init
    _init();
  }

  @override
  void dispose() {
    playerState.removeListener(notifyListeners);
    super.dispose();
  }

  Future<void> _init() async {
    songsValue = AsyncValue.loading();
    notifyListeners();
    try {
      // 1 - Fetch songs
      List<Song> songs = await songRepository.fetchSongs();
      songsValue = AsyncValue.success(songs);
    } catch (e) {
      songsValue = AsyncValue.error(e);
    }

    // 2 - notify listeners
    notifyListeners();
  }

  bool isSongPlaying(Song song) => playerState.currentSong == song;

  void start(Song song) => playerState.start(song);
  void stop(Song song) => playerState.stop();
}
