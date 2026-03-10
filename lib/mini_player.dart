import 'package:audiobox/music_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:marquee/marquee.dart';

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
    return StreamBuilder<int?>(
      stream: _musicService.audioPlayer.currentIndexStream,
      builder: (context, snapshot) {
        final index = snapshot.data;

        // If index is null (player hasn't started/no songs), hide the player
        if (index == null || _musicService.songs.isEmpty) {
          return const SizedBox.shrink();
        }

        // Get the current song based on the index emitted by the stream
        final currentSong = _musicService.songs[index];

        return GestureDetector(
          onTap: widget.onTap,
          child: Container(
            height: 64,
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF252525),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                // --- ARTWORK ---
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: QueryArtworkWidget(
                    id: currentSong.id,
                    type: ArtworkType.AUDIO,
                    artworkWidth: 40,
                    artworkHeight: 40,
                    nullArtworkWidget: Container(
                      width: 40,
                      height: 40,
                      color: const Color(0xFF1C1C1E),
                      child: const Icon(
                        Icons.music_note,
                        color: Colors.white54,
                        size: 20,
                      ),
                    ),
                  ),
                ),

                // --- MOVING TITLE ---
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: SizedBox(
                      height: 22, // Fixed height for the title area
                      child: Marquee(
                        key: ValueKey(currentSong.id),
                        text: currentSong.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        scrollAxis: Axis.horizontal,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        blankSpace:
                            50.0, // Space between end of text and start of next loop
                        velocity: 30.0, // Speed of scrolling
                        pauseAfterRound: const Duration(
                          seconds: 2,
                        ), // Pause at start
                        startPadding: 0.0,
                        accelerationDuration: const Duration(seconds: 1),
                        accelerationCurve: Curves.linear,
                        decelerationDuration: const Duration(milliseconds: 500),
                        decelerationCurve: Curves.easeOut,
                      ),
                    ),
                  ),
                ),
                // --- CONTROLS ---
                StreamBuilder<PlayerState>(
                  stream: _musicService.audioPlayer.playerStateStream,
                  builder: (context, snapshot) {
                    final playing = snapshot.data?.playing ?? false;

                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Play/Pause Button
                        IconButton(
                          onPressed: () {
                            playing
                                ? _musicService.audioPlayer.pause()
                                : _musicService.audioPlayer.play();
                            widget.onPlayPause();
                          },
                          icon: Icon(
                            playing
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),

                        // Skip Next Button with Automatic Dimming
                        StreamBuilder<SequenceState?>(
                          stream: _musicService.audioPlayer.sequenceStateStream,
                          builder: (context, snapshot) {
                            final sequenceState = snapshot.data;

                            // Check manually: Is the current index NOT the last one in the list?
                            final hasNext =
                                (sequenceState?.currentIndex ?? 0) <
                                ((sequenceState?.sequence.length ?? 0) - 1);

                            return IconButton(
                              onPressed: hasNext
                                  ? () async {
                                      await _musicService.skipNext();
                                      widget.onPlayPause();
                                    }
                                  : null,
                              icon: Icon(
                                Icons.skip_next_rounded,
                                color: hasNext ? Colors.white : Colors.white38,
                                size: 26,
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
