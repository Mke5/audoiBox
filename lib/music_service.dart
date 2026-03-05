import 'dart:io';
import 'package:audiobox/song_model.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class MusicService {
  static final MusicService _instance = MusicService._internal();
  factory MusicService() => _instance;

  MusicService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  List<Song> _songs = [];
  int _currentSongIndex = -1;

  AudioPlayer get audioPlayer => _audioPlayer;
  List<Song> get songs => _songs;
  int get currentSongIndex => _currentSongIndex;
  Song? get currentSong => _songs.isNotEmpty ? _songs[_currentSongIndex] : null;

  Future<List<Song>> _scanForSongs() async {
    _songs.clear();
    try {
      final allDirectories = await _getAllStorageDirectories();
      for (String dirPath in allDirectories) {
        await _scanDirectoryRecursively(dirPath);
      }
      _songs = _removeDuplicates(_songs);
      _songs.sort(
        (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
      );
    } catch (e) {
      print("Error scanning for songs: $e");
    }
    return _songs;
  }

  Future<List<String>> _getAllStorageDirectories() async {
    List<String> directories = [];
    final primaryPaths = [
      '/storage/emulated/0', // Internal storage
      '/storage/emulated/0/Music', // Music directory on internal storage
      '/storage/emulated/0/Media', // Music directory on internal storage
      '/storage/emulated/0/Audio', // Music directory on internal storage
      '/storage/emulated/0/Podcasts', // Music directory on internal storage
      '/storage/emulated/0/AudioBooks', // Music directory on internal storage
      '/storage/emulated/0/Download', // Downloads directory on internal storage
      '/storage/emulated/0/Android/data',
      '/storage/emulated/0/Android/media',
      '/storage/sdcard',
    ];

    final secondaryPaths = [
      '/storage/sdcard1',
      '/storage/sdcard2',
      '/storage/emulated/1',
      '/storage/extSdCard',
      '/storage/usb1',
      '/storage/usb2',
      '/storage/usb_storage',
    ];
    directories.addAll(primaryPaths);
    directories.addAll(secondaryPaths);

    try {
      final storageDir = Directory('/storage');
      if (await storageDir.exists()) {
        await for (FileSystemEntity entity in storageDir.list(
          recursive: false,
        )) {
          if (entity is Directory && !directories.contains(entity.path)) {
            directories.add(entity.path);
          }
        }
      }
    } catch (e) {
      print("Error getting storage directories: $e");
    }
    List<String> existingDirs = [];
    for (String dir in directories) {
      try {
        if (await Directory(dir).exists()) {
          existingDirs.add(dir);
        }
      } catch (e) {
        print("Error checking directory: $e");
        continue;
      }
    }
    return existingDirs;
  }

  Future<void> _scanDirectoryRecursively(String dirPath) async {
    try {
      final dir = Directory(dirPath);
      if (!await dir.exists()) {
        return;
      }
      await for (FileSystemEntity entity in dir.list(
        recursive: true,
        followLinks: false,
      )) {
        if (entity is Directory) {
          await _scanDirectoryRecursively(entity.path);
        } else if (entity is File && _isAudioFile(entity.path)) {
          try {
            final song = await _createSongFromFile(entity);
            if (song != null) {
              _songs.add(song);
            }
          } catch (e) {
            print("Error processing file ${entity.path}: $e");
            continue;
          }
        }
      }
    } catch (e) {
      print("Error scanning directory: $e");
      return;
    }
  }

  bool _isAudioFile(String filePath) {
    // final extension = path.split('.').last.toLowerCase();
    final extension = path.extension(filePath).toLowerCase();
    return [
      'mp3',
      'wav',
      'flac',
      'aac',
      'ogg',
      'm4a',
      'wma',
      'opus',
    ].contains(extension);
  }

  Future<Song?> _createSongFromFile(File file) async {
    try {
      final fileName = path.basenameWithoutExtension(file.path);
      String title = fileName;
      String artist = 'Unknown Artist';
      String album = 'Unknown Album';
      Duration duration = Duration.zero;

      try {
        final tempPlayer = AudioPlayer();
        // await tempPlayer.setUrl(file.path)
        await tempPlayer.setFilePath(file.path);
        if (tempPlayer.duration != null) {
          duration = tempPlayer.duration ?? Duration.zero;
        }
        await tempPlayer.dispose();
      } catch (e) {
        if (fileName.contains(' - ')) {
          final parts = fileName.split(' - ');
          if (parts.length >= 3) {
            artist = parts[0].trim();
            title = parts.sublist(1).join(' - ').trim();
            album = parts[2].trim();
          }
        }
      }
      return Song(
        title: title,
        artist: artist,
        album: album,
        duration: duration,
        path: file.path,
      );
    } catch (e) {
      print("Error creating song from file ${file.path}: $e");
      return null;
    }
  }

  List<Song> _removeDuplicates(List<Song> songs) {
    final seen = <String>{};
    return songs.where((song) {
      final key = '${song.title}-${song.artist}-${song.duration.inSeconds}';
      if (seen.contains(key)) {
        return false;
      }
      return seen.add(key);
    }).toList();
  }

  Future<void> playSongs(int index) async {
    if (index >= 0 && index < _songs.length) {
      _currentSongIndex = index;
      await _audioPlayer.setFilePath(_songs[index].path);
      await _audioPlayer.play();
    }
  }

  Future<void> pauseSongs() async {
    if (_audioPlayer.playing) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
  }

  Future<void> stopSongs() async {
    await _audioPlayer.stop();
  }

  Future<void> skipNext() async {
    if (_currentSongIndex < _songs.length - 1) {
      await playSongs(_currentSongIndex + 1);
    } else {
      await playSongs(0); // loop back to the first song
    }
  }

  Future<void> skipPrevious() async {
    if (_currentSongIndex > 0) {
      await playSongs(_currentSongIndex - 1);
    } else {
      await playSongs(_songs.length - 1); // loop back to the last song
    }
  }

  Future<void> seekTo(Duration position) async {
    await _audioPlayer.seek(position);
  }

  void shufflePlaylist() {
    if (_songs.length > 1) {
      final currentSong = _songs[_currentSongIndex];
      _songs.shuffle();

      final newIndex = _songs.indexOf(currentSong);
      if (newIndex != _currentSongIndex) {
        final temp = _songs[_currentSongIndex];
        _songs[_currentSongIndex] = currentSong;
        _songs[newIndex] = temp;
      }
    }
  }

  void dispose() {
    _audioPlayer.dispose();
    _songs.clear();
    _currentSongIndex = -1;
  }
}
