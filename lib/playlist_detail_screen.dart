import 'package:flutter/material.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:audiobox/music_service.dart';

class PlaylistDetailScreen extends StatefulWidget {
  final String playlistName;
  final int playlistId;

  const PlaylistDetailScreen({
    super.key,
    required this.playlistName,
    required this.playlistId,
  });

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  final _musicService = MusicService();

  void _refresh() => setState(() {});

  Widget _buildPlaceholder() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.music_note, color: Colors.white24),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // Using CustomScrollView to accommodate a Shuffle Header
      body: FutureBuilder<List<SongModel>>(
        future: OnAudioQuery().queryAudiosFrom(
          AudiosFromType.PLAYLIST,
          widget.playlistId,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFC3C44)),
            );
          }

          final songs = snapshot.data ?? [];

          return CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                backgroundColor: Colors.black,
                pinned: true,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: Color(0xFFFC3C44),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                  widget.playlistName,
                  style: const TextStyle(color: Colors.white),
                ),
              ),

              // Songs List
              songs.isEmpty
                  ? const SliverFillRemaining(
                      child: Center(
                        child: Text(
                          "No songs in this playlist",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final song = songs[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: QueryArtworkWidget(
                              id: song.id,
                              type: ArtworkType.AUDIO,
                              nullArtworkWidget: _buildPlaceholder(),
                            ),
                            title: Text(
                              song.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              song.artist ?? "Unknown Artist",
                              style: const TextStyle(color: Colors.grey),
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.remove_circle_outline,
                                color: Colors.grey,
                                size: 20,
                              ),
                              onPressed: () => _showRemoveDialog(context, song),
                            ),
                            onTap: () => _musicService.playPlaylist(
                              songs,
                              initialIndex: index,
                            ),
                          );
                        }, childCount: songs.length),
                      ),
                    ),
            ],
          );
        },
      ),
    );
  }

  // --- DELETE DIALOG ---
  void _showRemoveDialog(BuildContext context, SongModel song) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Remove Song", style: TextStyle(color: Colors.white)),
        content: Text(
          "Remove '${song.title}' from this playlist?",
          style: const TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              await OnAudioQuery().removeFromPlaylist(
                widget.playlistId,
                song.id,
              );
              if (mounted) {
                Navigator.pop(context);
                _refresh();
              }
            },
            child: const Text(
              "Remove",
              style: TextStyle(
                color: Color(0xFFFC3C44),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
