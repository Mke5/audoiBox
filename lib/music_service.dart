import 'package:audio_session/audio_session.dart';
import 'package:audiobox/song_model.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:path/path.dart' as path;

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

  Song? get currentSong {
    final index = _audioPlayer.currentIndex;
    if (index != null && index < _songs.length) {
      return _songs[index];
    }
    return null;
  }

  Future<void> initAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    session.becomingNoisyEventStream.listen((_) => _audioPlayer.pause());

    session.interruptionEventStream.listen((event) {
      if (event.begin) _audioPlayer.pause();
    });

    // No need for a manual listener for "completed" anymore!
    // ConcatenatingAudioSource handles auto-advance automatically.
  }

  Future<List<Song>> scanForSongs() async {
    bool permission = await _audioQuery.permissionsStatus();
    if (!permission) permission = await _audioQuery.permissionsRequest();
    if (!permission) return [];

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

    // Initialize the automatic playlist
    _playlist = ConcatenatingAudioSource(
      children: _songs.map((song) => AudioSource.file(song.path)).toList(),
    );

    // Load the entire playlist into the player once
    await _audioPlayer.setAudioSource(_playlist);

    return _songs;
  }

  Future<void> playSongs(int index) async {
    try {
      await _audioPlayer.seek(Duration.zero, index: index);
      await _audioPlayer.play();
      print("Playing: ${_songs[index].title}");
    } catch (e) {
      print("Error playing song: $e");
    }
  }

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

  void dispose() {
    _audioPlayer.dispose();
    _songs.clear();
  }
}
