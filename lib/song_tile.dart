import 'package:audiobox/music_service.dart';
import 'package:audiobox/song_model.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';

class SongTile extends StatelessWidget {
  final Song song;
  final bool isPlaying;
  final bool isActuallyPlaying;
  final VoidCallback onTap;

  const SongTile({
    super.key,
    required this.song,
    required this.isPlaying,
    this.isActuallyPlaying = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final musicService = MusicService();

    // Guard for database loading
    if (!musicService.isDbReady || !Hive.isBoxOpen('favorites')) {
      return _buildTile(context, isLiked: false);
    }

    // Wrap the entire tile or just the menu with the listener
    return ValueListenableBuilder<Box<int>>(
      valueListenable: Hive.box<int>('favorites').listenable(),
      builder: (context, box, _) {
        final isLiked = box.containsKey(song.id);
        return _buildTile(context, isLiked: isLiked);
      },
    );
  }

  Widget _buildTile(BuildContext context, {required bool isLiked}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              // --- ARTWORK SECTION ---
              _buildArtwork(),
              const SizedBox(width: 14),

              // --- TITLE AND ARTIST ---
              _buildSongDetails(),

              // --- THREE DOTS MENU ---
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert,
                  color: Colors.white54,
                  size: 22,
                ),
                color: const Color(0xFF1C1C1E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (value) async {
                  if (value == 'favorite') {
                    await MusicService().toggleFavorite(song.id);
                  } else if (value == 'share') {
                    // Share logic
                  }
                },
                itemBuilder: (BuildContext context) => [
                  // DYNAMIC FAVORITE ITEM
                  PopupMenuItem(
                    value: 'favorite',
                    child: Row(
                      children: [
                        Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          color: isLiked
                              ? const Color(0xFFFC3C44)
                              : Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          isLiked
                              ? 'Remove from Favorites'
                              : 'Add to Favorites',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'share',
                    child: Row(
                      children: [
                        Icon(
                          Icons.share_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Share Song',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline,
                          color: Color(0xFFFC3C44),
                          size: 20,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Delete',
                          style: TextStyle(color: Color(0xFFFC3C44)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArtwork() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Opacity(
          opacity: isPlaying ? 0.6 : 1.0,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: QueryArtworkWidget(
              id: song.id,
              type: ArtworkType.AUDIO,
              artworkWidth: 50,
              artworkHeight: 50,
              nullArtworkWidget: Container(
                height: 50,
                width: 50,
                color: const Color(0xFF2C2C2E),
                child: const Icon(Icons.music_note, color: Colors.white54),
              ),
            ),
          ),
        ),
        if (isPlaying)
          Icon(
            isActuallyPlaying
                ? Icons.bar_chart_rounded
                : Icons.play_arrow_rounded,
            color: Colors.white,
            size: 24,
          ),
      ],
    );
  }

  Widget _buildSongDetails() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            song.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isPlaying ? const Color(0xFFFC3C44) : Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            song.artist,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
          ),
        ],
      ),
    );
  }
}
