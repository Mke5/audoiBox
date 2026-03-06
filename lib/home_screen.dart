import 'package:audiobox/music_screen.dart';
import 'package:audiobox/music_service.dart';
import 'package:audiobox/song_model.dart';
import 'package:audiobox/song_tile.dart';
import 'package:flutter/material.dart';

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
      appBar: AppBar(
        title: Text('Audiobox'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadSongs),
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
                        CircularProgressIndicator(color: Colors.purple),
                        SizedBox(height: 20),
                        Text(
                          'Loading songs',
                          style: TextStyle(color: Colors.white),
                        ), // Text
                      ],
                    ),
                  ) // Center
                : _songs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.music_off,
                          size: 80,
                          color: Colors.grey[600],
                        ),
                        Text(
                          'No songs found',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadSongs,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            foregroundColor: Colors.white,
                          ),
                          child: Text('Scan Again'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: _songs.length,
                    itemBuilder: (context, index) {
                      return SongTile(
                        song: _songs[index],
                        isPlaying: _musicService.currentSongIndex == index,
                        onTap: () => _onSongTap(index),
                      );
                    },
                  ), // ListView.builder
          ), // Expanded
          // if(_musicService.currentSong != null){
          //   MiniPlayer(
          //     onTap: _openMusicScreen,
          //     onPlayPause: () async {
          //       await _musicService.pauseSong;

          //     }
          //   ), // MiniPlayer
          // }
        ],
      ), // Column
    ); // Scaffold
  }
}
