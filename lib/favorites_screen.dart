import 'package:audiobox/music_service.dart';
import 'package:audiobox/song_model.dart';
import 'package:audiobox/song_tile.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: ValueListenableBuilder<Box<int>>(
        // Listen to the Hive box defined in MusicService
        valueListenable: Hive.box<int>('favorites').listenable(),
        builder: (context, box, _) {
          // Get current favorites from service
          final allFavorites = MusicService().favoriteSongs;

          // Apply search filtering
          final filteredSongs = allFavorites.where((s) {
            final query = _searchQuery.toLowerCase();
            return s.title.toLowerCase().contains(query) ||
                s.artist.toLowerCase().contains(query);
          }).toList();

          return CustomScrollView(
            slivers: [
              _buildAppBar(),
              _buildSearchBar(),
              if (allFavorites.isNotEmpty) _buildActionButtons(filteredSongs),
              if (allFavorites.isEmpty)
                SliverFillRemaining(child: _buildEmptyState())
              else
                _buildSliverList(filteredSongs),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar() {
    return const SliverAppBar(
      expandedHeight: 110.0,
      pinned: true,
      backgroundColor: Colors.black,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsetsDirectional.only(start: 16, bottom: 16),
        centerTitle: false,
        title: Text(
          "Favorites",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return SliverToBoxAdapter(
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
            hintText: 'Find in favorites',
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
            prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 22),
            contentPadding: const EdgeInsets.symmetric(vertical: 0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.music_off, size: 60, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            'No favorites yet',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverList(List<Song> songs) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 150),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final song = songs[index];

          // --- ADD THIS STREAM BUILDER ---
          return StreamBuilder<SequenceState?>(
            stream: MusicService().audioPlayer.sequenceStateStream,
            builder: (context, snapshot) {
              final state = snapshot.data;
              if (state == null) return const SizedBox();

              // Check if the current playing media matches this favorite song's ID
              final currentItem = state.currentSource?.tag as MediaItem?;
              final bool isCurrentSong = currentItem?.id == song.id.toString();

              return SongTile(
                song: song,
                isPlaying: isCurrentSong, // Highlights the title in red
                isActuallyPlaying:
                    isCurrentSong && MusicService().audioPlayer.playing,
                onTap: () => MusicService().playSongs(index, customList: songs),
              );
            },
          );
        }, childCount: songs.length),
      ),
    );
  }

  Widget _buildActionButtons(List<Song> songs) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            // PLAY ALL BUTTON
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1C1C1E),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => MusicService().playSongs(0, customList: songs),
                icon: const Icon(Icons.play_arrow),
                label: const Text("Play"),
              ),
            ),
            const SizedBox(width: 12),
            // SHUFFLE BUTTON
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1C1C1E),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  var shuffled = List<Song>.from(songs)..shuffle();
                  MusicService().playSongs(0, customList: shuffled);
                },
                icon: const Icon(Icons.shuffle),
                label: const Text("Shuffle"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
