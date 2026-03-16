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
  final TextEditingController _searchController = TextEditingController();

  List<Song> _songs = [];
  bool _isLoading = true;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _loadSongs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSongs() async {
    setState(() => _isLoading = true);
    _songs = await _musicService.scanForSongs();
    setState(() => _isLoading = false);
  }

  List<Song> get _filteredSongs {
    if (_searchQuery.isEmpty) return _songs;
    return _songs
        .where(
          (s) =>
              s.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              s.artist.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  void _openMusicScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MusicScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // Prevents the keyboard from pushing the MiniPlayer up
      resizeToAvoidBottomInset: false,
      body: CustomScrollView(
        slivers: [
          // --- LARGE TITLE APP BAR ---
          SliverAppBar(
            expandedHeight: 110.0,
            floating: false,
            pinned: true,
            backgroundColor: Colors.black,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsetsDirectional.only(
                start: 16,
                bottom: 16,
              ),
              centerTitle: false,
              title: const Text(
                'Audiobox',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: _loadSongs,
              ),
              StreamBuilder<bool>(
                stream: _musicService.audioPlayer.shuffleModeEnabledStream,
                builder: (context, snapshot) {
                  final isShuffle = snapshot.data ?? false;
                  return IconButton(
                    icon: Icon(
                      Icons.shuffle,
                      color: isShuffle ? const Color(0xFFFC3C44) : Colors.white,
                    ),
                    onPressed: () => _musicService.toggleShuffle(),
                  );
                },
              ),
            ],
          ),

          // --- APPLE STYLE SEARCH BAR ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val),
                style: const TextStyle(color: Colors.white, fontSize: 16),
                cursorColor: const Color(0xFFFC3C44),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF1C1C1E),
                  hintText: 'Songs, Artists, or Albums',
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.grey,
                    size: 22,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.cancel,
                            color: Colors.grey,
                            size: 20,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = "");
                          },
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),

          // --- CONTENT STATE ---
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFFFC3C44)),
              ),
            )
          else if (_filteredSongs.isEmpty)
            SliverFillRemaining(child: _buildEmptyState())
          else
            _buildSliverSongList(),
        ],
      ),
    );
  }

  Widget _buildSliverSongList() {
    return StreamBuilder<int?>(
      stream: _musicService.audioPlayer.currentIndexStream,
      builder: (context, indexSnapshot) {
        final currentIndex = indexSnapshot.data;
        return StreamBuilder<PlayerState>(
          stream: _musicService.audioPlayer.playerStateStream,
          builder: (context, snapshot) {
            final playing = snapshot.data?.playing ?? false;
            final songsToDisplay = _filteredSongs;

            return SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 150),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final song = songsToDisplay[index];
                  final globalIndex = _songs.indexOf(song);
                  final bool isCurrentTrack = globalIndex == currentIndex;

                  return SongTile(
                    song: song,
                    isPlaying: isCurrentTrack,
                    isActuallyPlaying: isCurrentTrack && playing,
                    onTap: () => _musicService.playSongs(globalIndex),
                  );
                }, childCount: songsToDisplay.length),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.music_off, size: 60, color: Colors.grey),
          const SizedBox(height: 12),
          const Text(
            'No songs found',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          TextButton(
            onPressed: _loadSongs,
            child: const Text(
              'Refresh Library',
              style: TextStyle(color: Color(0xFFFC3C44)),
            ),
          ),
        ],
      ),
    );
  }
}
