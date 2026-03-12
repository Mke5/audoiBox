import 'package:audio_session/audio_session.dart';
import 'package:audiobox/song_model.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';

class MusicService {
  static final MusicService _instance = MusicService._internal();
  factory MusicService() => _instance;

  MusicService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  final OnAudioQuery _audioQuery = OnAudioQuery();

  List<Song> _songs = [];
  late ConcatenatingAudioSource _playlist;

  List<Song> get songs => _songs;
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

  Future<void> playSongs(int index) async {
    try {
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
