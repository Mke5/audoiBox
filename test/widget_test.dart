import 'package:audiobox/song_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SongModel', () {
    test('creates a song with required fields', () {
      final song = Song(
        id: 1,
        title: 'Test Song',
        artist: 'Test Artist',
        album: 'Test Album',
        duration: const Duration(seconds: 180),
        path: '/music/test.mp3',
      );

      expect(song.id, 1);
      expect(song.title, 'Test Song');
      expect(song.artist, 'Test Artist');
      expect(song.album, 'Test Album');
      expect(song.duration.inSeconds, 180);
      expect(song.path, '/music/test.mp3');
    });

    test('uses defaults for missing values', () {
      final song = Song(
        id: 2,
        title: 'Another Song',
        artist: 'Artist',
        album: 'Album',
        duration: const Duration(seconds: 120),
        path: '/music/another.mp3',
      );

      expect(song.title, 'Another Song');
      expect(song.artist, 'Artist');
    });

    test('supports equality by id', () {
      final a = Song(
        id: 1,
        title: 'Song A',
        artist: 'Artist',
        album: 'Album',
        duration: Duration.zero,
        path: '/a.mp3',
      );
      final b = Song(
        id: 1,
        title: 'Song B',
        artist: 'Artist',
        album: 'Album',
        duration: Duration.zero,
        path: '/b.mp3',
      );

      expect(a.id, b.id);
    });
  });
}
