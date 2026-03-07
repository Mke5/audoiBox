import 'package:audiobox/music_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class MiniPlayer extends StatefulWidget {
  final VoidCallback onTap;
  final VoidCallback onPlayPause;
  const MiniPlayer({super.key, required this.onTap, required this.onPlayPause});

  @override
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> {
  final MusicService _musicService = MusicService();
  @override
  Widget build(BuildContext context) {
    final currentSong = _musicService.currentSong;
    if (currentSong == null) {
      return const SizedBox.shrink();
    }
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        height: 70,
        margin: EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2A2A2A), Color(0xFF1A1A1A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ), // LinearGradient
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ], // boxShadow
        ), // BoxDecoration
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              margin: EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple, Colors.deepPurple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ), // LinearGradient
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.music_note, color: Colors.white, size: 30),
            ), // Container
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentSong.title,
                    style: TextStyle(
                      color: Colors.white,
                      // fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ), // TextStyle
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ), // Text
                  SizedBox(height: 4),
                  Text(
                    currentSong.artist,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ), // TextStyle
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ), // Text
                ], // Children
              ), // Column
            ), // Expanded
            StreamBuilder<PlayerState>(
              stream: _musicService.audioPlayer.playerStateStream,
              builder: (context, snapshot) {
                final playerState = snapshot.data;
                final playing =
                    playerState?.playing ?? _musicService.audioPlayer.playing;
                final processingState = playerState?.processingState;

                if (processingState == ProcessingState.loading ||
                    processingState == ProcessingState.buffering) {
                  return const SizedBox(
                    width: 48,
                    height: 48,
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  );
                } else {
                  return IconButton(
                    icon: Icon(
                      playing ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      if (playing) {
                        _musicService.audioPlayer.pause();
                      } else {
                        _musicService.audioPlayer.play();
                      }
                      widget.onPlayPause();
                    },
                  );
                }
              },
            ),
          ],
        ), // Row
      ), // Container
    ); // GestureDetector
  }
}
