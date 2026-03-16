import 'package:audiobox/song_model.dart';
import 'package:audiobox/song_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  final List<Song> _favoriteSongs = [];

  List<Song> get _filteredFavorites {
    if (_searchQuery.isEmpty) return _favoriteSongs;
    return _favoriteSongs
        .where(
          (s) =>
              s.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              s.artist.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
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
              title: Text(
                "Favorites",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ), // TextStyle
              ), // Text
            ), // FlexibleSpacebar
          ), // SilverAppBar
          // --- SEARCH BAR (Matches HomeScreen) ---
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
                  hintText: 'Find in songs',
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.grey,
                    size: 22,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ), // InputDecoration
              ), // TextField
            ), // Padding
          ), // SliverToBoxAdapter
          // --- CONTENT ---
          if (_favoriteSongs.isEmpty)
            SliverFillRemaining(child: _buildEmptyState())
          else
            _buildSliverList(),
        ],
      ), // CustomScrollView
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
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

  Widget _buildSliverList() {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        16,
        8,
        16,
        150,
      ), // Extra bottom padding for floating player
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final song = _filteredFavorites[index];
          return SongTile(
            song: song,
            isPlaying: false,
            isActuallyPlaying: false,
            onTap: () {
              // Future functionality
            },
          );
        }, childCount: _filteredFavorites.length),
      ),
    );
  }
}
