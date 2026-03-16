import 'package:audiobox/music_service.dart';
import 'package:audiobox/playlist_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';

class PlaylistsScreen extends StatefulWidget {
  const PlaylistsScreen({super.key});

  @override
  State<PlaylistsScreen> createState() => _PlaylistsScreenState();
}

class _PlaylistsScreenState extends State<PlaylistsScreen> {
  final _musicService = MusicService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  // Helper to trigger a refresh of the FutureBuilder
  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [_buildAppBar(), _buildSearchBar(), _buildPlaylistList()],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 110.0,
      pinned: true,
      backgroundColor: Colors.black,
      elevation: 0,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: IconButton(
            icon: const Icon(Icons.add, color: Color(0xFFFC3C44), size: 28),
            onPressed: () => _showCreatePlaylistDialog(context),
          ),
        ),
      ],
      flexibleSpace: const FlexibleSpaceBar(
        titlePadding: EdgeInsetsDirectional.only(start: 16, bottom: 16),
        centerTitle: false,
        title: Text(
          "Playlists",
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
          onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
          style: const TextStyle(color: Colors.white, fontSize: 16),
          cursorColor: const Color(0xFFFC3C44),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF1C1C1E),
            hintText: 'Find in playlists',
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
            prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 22),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaylistList() {
    return FutureBuilder<List<PlaylistModel>>(
      future: _musicService.queryPlaylists(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverFillRemaining(
            child: Center(
              child: CircularProgressIndicator(color: Color(0xFFFC3C44)),
            ),
          );
        }

        final playlists = snapshot.data ?? [];
        final filteredPlaylists = playlists.where((p) {
          return p.playlist.toLowerCase().contains(_searchQuery);
        }).toList();

        return SliverPadding(
          // 3. Keep the bottom padding high (150) so the last item clears the miniplayer
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 150),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              // 4. Remove the if(index == 0) "Create" tile logic completely
              final playlist = filteredPlaylists[index];

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
                ),
                title: Text(
                  playlist.playlist,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  '${playlist.numOfSongs} songs',
                  style: const TextStyle(color: Colors.grey),
                ),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                onLongPress: () =>
                    _showDeleteDialog(playlist.id, playlist.playlist),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlaylistDetailScreen(
                        playlistName: playlist.playlist,
                        playlistId:
                            playlist.id, // Passing ID is better for MediaStore
                      ),
                    ),
                  ).then((_) => _refresh());
                },
              );
            }, childCount: filteredPlaylists.length),
          ),
        );
      },
    );
  }

  // --- ACTIONS ---

  void _showCreatePlaylistDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        // Matching your search bar background
        backgroundColor: const Color(0xFF1C1C1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // Softer, modern corners
        ),
        title: const Text(
          "New Playlist",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          autofocus: true,
          cursorColor: const Color(0xFFFC3C44), // Brand Red
          decoration: InputDecoration(
            hintText: "Enter name",
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
            // Adding a subtle underline or border to match a "clean" look
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFFC3C44), width: 2),
            ),
          ),
        ),
        actions: [
          // Standard grey for non-primary actions
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ),
          // Bold Brand Red for the primary action
          TextButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                await _musicService.createPlaylist(controller.text);
                if (mounted) Navigator.pop(context);
                _refresh();
              }
            },
            child: const Text(
              "Create",
              style: TextStyle(
                color: Color(0xFFFC3C44),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(int id, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "Delete $name?",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          "This will permanently remove the playlist from your device. The songs inside will not be deleted.",
          style: TextStyle(color: Colors.grey, fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ),
          TextButton(
            onPressed: () async {
              // Ensure removePlaylist is implemented in your MusicService
              await _musicService.removePlaylist(id);
              if (mounted) Navigator.pop(context);
              _refresh();
            },
            child: const Text(
              "Delete",
              style: TextStyle(
                color: Colors.redAccent, // Red for destructive actions
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
