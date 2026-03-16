import 'package:audio_session/audio_session.dart';
import 'package:audiobox/song_model.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';

class MusicService {
  static final MusicService _instance = MusicService._internal();
  factory MusicService() => _instance;
  bool _isDbReady = false;
  bool get isDbReady => _isDbReady;

  MusicService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  final OnAudioQuery _audioQuery = OnAudioQuery();

  List<Song> _songs = [];
  late ConcatenatingAudioSource _playlist;

  static const String _favoritesBoxName = 'favorites';

  Future<void> initDatabase() async {
    try {
      await Hive.initFlutter();
      // Open the box. We use <int> because we only need to store Song IDs.
      if (!Hive.isBoxOpen(_favoritesBoxName)) {
        await Hive.openBox<int>(_favoritesBoxName);
      }
      _isDbReady = true;
    } catch (e) {
      print("error OPening box Hive: $e");
    }
  }

  List<Song> get songs => _songs;

  // Check if song is liked
  bool isFavorite(int songId) {
    final box = Hive.box<int>(_favoritesBoxName);
    return box.containsKey(songId);
  }

  // Toggle Favorite
  Future<void> toggleFavorite(int songId) async {
    final box = Hive.box<int>(_favoritesBoxName);
    if (isFavorite(songId)) {
      await box.delete(songId);
    } else {
      await box.put(songId, songId);
    }
  }

  // Get list of favorite songs
  List<Song> get favoriteSongs {
    final box = Hive.box<int>(_favoritesBoxName);
    final favoriteIds = box.keys.toSet();
    return _songs.where((song) => favoriteIds.contains(song.id)).toList();
  }

  // Returns a unique list of artist names based on the scanned songs
  List<String> get artists {
    return _songs.map((s) => s.artist).toSet().toList()..sort();
  }

  // Returns all songs by a specific artist
  List<Song> getSongsByArtist(String artistName) {
    return _songs.where((s) => s.artist == artistName).toList();
  }

  Future<List<PlaylistModel>> queryPlaylists() async {
    return await _audioQuery.queryPlaylists();
  }

  Future<List<Song>> getSongsFromPlaylist(int playlistId) async {
    final playlistSongs = await _audioQuery.queryAudiosFrom(
      AudiosFromType.PLAYLIST,
      playlistId,
    );
    // Map these back to your Song model as you did in scanForSongs
    return playlistSongs
        .map(
          (s) => Song(
            id: s.id,
            title: s.title,
            artist: s.artist ?? "Unknown Artist",
            album: s.album ?? "Unknown Album",
            duration: Duration(milliseconds: s.duration ?? 0),
            path: s.data,
          ),
        )
        .toList();
  }

  AudioPlayer get audioPlayer => _audioPlayer;

  // --- Helper to create AudioSource with Metadata ---
  // This is CRITICAL for your MusicScreen to show the title/artist
  AudioSource _createAudioSource(Song song) {
    return AudioSource.uri(
      Uri.parse(song.path),
      tag: MediaItem(
        id: song.id.toString(),
        album: song.album,
        title: song.title,
        artist: song.artist,
        // Using the file path for artwork query purposes
        artUri: Uri.parse('file://${song.path}'),
      ),
    );
  }

  Future<void> initAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    session.becomingNoisyEventStream.listen((_) => _audioPlayer.pause());

    session.interruptionEventStream.listen((event) {
      if (event.begin) _audioPlayer.pause();
    });
  }

  Future<List<Song>> scanForSongs() async {
    // Check permission using on_audio_query_pluse
    bool permission = await _audioQuery.permissionsStatus();
    if (!permission) permission = await _audioQuery.permissionsRequest();

    if (!permission) return [];

    // Querying the device
    final deviceSongs = await _audioQuery.querySongs(
      sortType: SongSortType.TITLE,
      orderType: OrderType.ASC_OR_SMALLER,
      uriType: UriType.EXTERNAL,
    );

    _songs = deviceSongs
        .map(
          (s) => Song(
            id: s.id,
            title: s.title,
            artist: s.artist ?? "Unknown Artist",
            album: s.album ?? "Unknown Album",
            duration: Duration(milliseconds: s.duration ?? 0),
            path: s.data,
          ),
        )
        .toList();

    if (_songs.isNotEmpty) {
      _playlist = ConcatenatingAudioSource(
        children: _songs.map((song) => _createAudioSource(song)).toList(),
      );
      await _audioPlayer.setAudioSource(_playlist);
    }

    return _songs;
  }

  Future<void> playSongs(int index, {List<Song>? customList}) async {
    try {
      List<Song> targetList = customList ?? _songs;
      _playlist = ConcatenatingAudioSource(
        children: targetList.map((song) => _createAudioSource(song)).toList(),
      );
      await _audioPlayer.setAudioSource(_playlist);
      // If shuffle is on, we seek to the index in the shuffled list
      await _audioPlayer.seek(Duration.zero, index: index);
      await _audioPlayer.play();
    } catch (e) {
      print("Error playing song: $e");
    }
  }

  // --- Controls ---

  Future<void> pauseSong() async => _audioPlayer.playing
      ? await _audioPlayer.pause()
      : await _audioPlayer.play();

  Future<void> skipNext() async => _audioPlayer.hasNext
      ? await _audioPlayer.seekToNext()
      : await _audioPlayer.seek(Duration.zero, index: 0);

  Future<void> skipPrevious() async => await _audioPlayer.seekToPrevious();

  Future<void> seekTo(Duration position) async =>
      await _audioPlayer.seek(position);

  void toggleShuffle() async {
    final isEnabled = !_audioPlayer.shuffleModeEnabled;
    await _audioPlayer.setShuffleModeEnabled(isEnabled);
  }

  void toggleRepeat() async {
    switch (_audioPlayer.loopMode) {
      case LoopMode.off:
        await _audioPlayer.setLoopMode(LoopMode.one);
        break;
      case LoopMode.one:
        await _audioPlayer.setLoopMode(LoopMode.all);
        break;
      case LoopMode.all:
        await _audioPlayer.setLoopMode(LoopMode.off);
        break;
    }
  }

  void dispose() {
    _audioPlayer.dispose();
    _songs.clear();
  }
}
