import 'package:audiobox/music_service.dart';
import 'package:flutter/material.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';

class ArtistDetailScreen extends StatelessWidget {
  final String artistName;
  final int artistId; // Added ID for artwork retrieval

  ArtistDetailScreen({
    super.key,
    required this.artistName,
    required this.artistId,
  });

  final MusicService _musicService = MusicService();

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
        title: Text(
          artistName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: FutureBuilder<List<SongModel>>(
        future: _musicService.querySongsByArtist(artistName),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFC3C44)),
            );
          }

          // Filter songs locally to ensure they belong to this artist
          final artistSongs =
              snapshot.data?.where((s) => s.artist == artistName).toList() ??
              [];

          if (artistSongs.isEmpty) {
            return const Center(
              child: Text(
                "No songs found",
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            itemCount: artistSongs.length,
            itemBuilder: (context, index) {
              final song = artistSongs[index];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: QueryArtworkWidget(
                  id: song.id,
                  type: ArtworkType.AUDIO,
                  nullArtworkWidget: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(Icons.music_note, color: Colors.grey),
                  ),
                ),
                title: Text(
                  song.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                subtitle: Text(
                  song.album ?? "Unknown Album",
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                onTap: () {
                  // Logic to play song goes here
                },
              );
            },
          );
        },
      ),
    );
  }
}
