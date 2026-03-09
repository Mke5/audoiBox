import 'package:audiobox/mini_player.dart';
import 'package:audiobox/music_screen.dart';
import 'package:audiobox/music_service.dart';
import 'package:audiobox/song_model.dart';
import 'package:audiobox/song_tile.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MusicService _musicService = MusicService();
  List<Song> _songs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSongs();
  }

  Future<void> _loadSongs() async {
    setState(() {
      _isLoading = true;
    });
    _songs = await _musicService.scanForSongs();
    setState(() {
      _isLoading = false;
    });
  }

  void _onSongTap(int index) async {
    await _musicService.playSongs(index);
    setState(() {});
  }

  void _openMusicScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MusicScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        backgroundColor: const Color(0xFF000000),
        title: Text('Audiobox',
          style: TextStyle(
            color: Color(0xFFFFFFFF),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ), // Text
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadSongs, color: Color(0xFFFFFFFF)),
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: () => _openMusicScreen(context),
          ), // Icon Buton
        ], // actions
      ), // AppBar
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Color(0xFFFC3C44)),
                        SizedBox(height: 20),
                        Text(
                          'Loading songs',
                          style: TextStyle(color: Colors.white),
                        ), // Text
                      ],
                    ),
                  ) // Center
                : _songs.isEmpty
                ? _buildEmptyState()
                : StreamBuilder<PlayerState>(
                  stream: _musicService.audioPlayer.playerStateStream,
                  builder: (context, snapshot) {
                    // 1. Get the current playing status (true/false)
                    final playing = snapshot.data?.playing ?? false;

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      itemCount: _songs.length,
                      itemBuilder: (context, index) {
                        // 2. Check if this specific tile is the one loaded in the player
                        final bool isCurrentTrack = _musicService.currentSongIndex == index;

                        return SongTile(
                          song: _songs[index],
                          isPlaying: isCurrentTrack,
                          // 3. Only shows the "Bars" if it's the active track AND it's not paused
                          isActuallyPlaying: isCurrentTrack && playing,
                          onTap: () => _onSongTap(index),
                        );
                      },
                    );
                  },
                )
          ), // Expanded
          if (_musicService.currentSong != null)
            MiniPlayer(
              onTap: () => _openMusicScreen(context),
              onPlayPause: () async {
                // await _musicService.pauseSong();
                setState(() {});
              },
            ), // MiniPlayer
        ],
      ), // Column
    ); // Scaffold
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.music_off, size: 80, color: Color(0xFF9CA3AF)), // textMuted
          const SizedBox(height: 16),
          const Text(
            'No songs found',
            style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 20),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadSongs,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFC3C44), // colors.primary
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Scan Again'),
          ),
        ],
      ),
    );
  }
}
