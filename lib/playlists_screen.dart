import 'package:audiobox/playlist_detail_screen.dart';
import 'package:flutter/material.dart';

class PlaylistsScreen extends StatefulWidget {
  const PlaylistsScreen({super.key});

  @override
  State<PlaylistsScreen> createState() => _PlaylistsScreenState();
}

class _PlaylistsScreenState extends State<PlaylistsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  // Mock data for UI
  final List<Map<String, dynamic>> _playlists = [
    {'name': 'Gym Mix', 'songCount': 12, 'image': null},
    {'name': 'Late Night Lo-fi', 'songCount': 45, 'image': null},
    {'name': 'Top Hits 2024', 'songCount': 20, 'image': null},
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
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
                "Playlists",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ), // TextStyle
              ), // Text
            ), // FlexibleSpacebar
          ), // SilverAppBar
          // Search Bar
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
                  hintText: 'Find in playlists',
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
          // Playlist List
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 150),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final playlist = _playlists[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.playlist_play,
                      color: Color(0xFFFC3C44),
                    ),
                  ), // Container
                  title: Text(
                    playlist['name'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    '${playlist['songCount']} songs',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlaylistDetailScreen(
                          playlistName: playlist['name'],
                        ),
                      ),
                    ); // Navigator.push
                  },
                );
              }, childCount: _playlists.length),
            ), // SliverList
          ), // SliverPadding
        ],
      ), // CustomScrollView
    );
  }
}
