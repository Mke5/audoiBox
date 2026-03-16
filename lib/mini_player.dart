import 'package:audiobox/music_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
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
    return StreamBuilder<SequenceState?>(
      stream: _musicService.audioPlayer.sequenceStateStream,
      builder: (context, snapshot) {
        final sequenceState = snapshot.data;

        // If index is null (player hasn't started/no songs), hide the player
        if (sequenceState == null || sequenceState.currentSource == null) {
          return const SizedBox.shrink();
        }

        // Get the current song based on the index emitted by the stream
        final currentSong = sequenceState.currentSource!.tag as MediaItem;

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
                    id: int.parse(currentSong.id),
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
                // --- CONTROLS SECTION (Updated) ---
                StreamBuilder<PlayerState>(
                  stream: _musicService.audioPlayer.playerStateStream,
                  builder: (context, snapshot) {
                    final playerState = snapshot.data;
                    final processingState = playerState?.processingState;
                    final playing = playerState?.playing ?? false;

                    // 1. Show a loading spinner if the song is buffering
                    if (processingState == ProcessingState.loading ||
                        processingState == ProcessingState.buffering) {
                      return Container(
                        margin: const EdgeInsets.all(8.0),
                        width: 24.0,
                        height: 24.0,
                        child: const CircularProgressIndicator(
                          color: Color(0xFFFC3C44),
                          strokeWidth: 2,
                        ),
                      );
                    }

                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // --- PLAY/PAUSE BUTTON ---
                        IconButton(
                          onPressed: () {
                            if (playing) {
                              _musicService.pauseSong();
                            } else {
                              // If the song ended, seek back to start and play
                              if (processingState ==
                                  ProcessingState.completed) {
                                _musicService.audioPlayer.seek(Duration.zero);
                              }
                              _musicService.audioPlayer.play();
                            }
                          },
                          icon: Icon(
                            playing
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        IconButton(
                          onPressed:
                              (sequenceState.currentIndex ?? 0) <
                                  (sequenceState.sequence.length - 1)
                              ? () => _musicService.audioPlayer.seekToNext()
                              : null,
                          icon: Icon(
                            Icons.skip_next_rounded,
                            color:
                                (sequenceState.currentIndex ?? 0) <
                                    (sequenceState.sequence.length - 1)
                                ? Colors.white
                                : Colors.white24,
                            size: 30,
                          ),
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
