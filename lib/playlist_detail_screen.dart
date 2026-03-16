import 'package:flutter/material.dart';

class PlaylistDetailScreen extends StatelessWidget {
  final String playlistName;
  const PlaylistDetailScreen({super.key, required this.playlistName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFFC3C44)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(playlistName, style: const TextStyle(color: Colors.white)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
        itemCount: 0, // We will populate this with actual playlist tracks later
        itemBuilder: (context, index) {
          // Return SongTile(...) here later
          return const SizedBox.shrink();
        },
      ),
    ); // Scaffold
  }
}
