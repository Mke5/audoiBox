import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audiobox/music_service.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:marquee/marquee.dart';

class MusicScreen extends StatefulWidget {
  const MusicScreen({super.key});
  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  final _musicService = MusicService();
  bool isFavorite = false; // Mock state for the heart icon

  String _formatDuration(Duration d) {
    return "${d.inMinutes.remainder(60).toString().padLeft(2, '0')}:${d.inSeconds.remainder(60).toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final song = _musicService.currentSong;
    if (song == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFFC3C44)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Background (You can add a blurred artwork here later like the RN version)
          Container(color: const Color(0xFF121212)),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  // --- DISMISS SYMBOL ---
                  const SizedBox(height: 8),
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  // --- TOP BAR ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 30,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        "NOW PLAYING",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_horiz, color: Colors.white),
                        onPressed: () {},
                      ),
                    ],
                  ),

                  const Spacer(),

                  // --- ALBUM ARTWORK ---
                  Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.85,
                      height: MediaQuery.of(context).size.width * 0.85,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.6),
                            blurRadius: 30,
                            offset: const Offset(0, 20),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: QueryArtworkWidget(
                          id: song.id,
                          type: ArtworkType.AUDIO,
                          artworkWidth: double.infinity,
                          artworkHeight: double.infinity,
                          nullArtworkWidget: Container(
                            color: const Color(0xFF1C1C1E),
                            child: const Icon(
                              Icons.music_note,
                              size: 100,
                              color: Colors.white24,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // --- TRACK INFO ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 35,
                              child: Marquee(
                                text: song.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                                blankSpace: 50,
                                velocity: 30,
                                pauseAfterRound: const Duration(seconds: 3),
                              ),
                            ),
                            Text(
                              song.artist,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 18,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () =>
                            setState(() => isFavorite = !isFavorite),
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite
                              ? const Color(0xFFFC3C44)
                              : Colors.white54,
                          size: 28,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // --- PROGRESS BAR ---
                  StreamBuilder<Duration?>(
                    stream: _musicService.audioPlayer.positionStream,
                    builder: (context, snapshot) {
                      final pos = snapshot.data ?? Duration.zero;
                      final dur =
                          _musicService.audioPlayer.duration ?? Duration.zero;
                      return Column(
                        children: [
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 4,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 6,
                              ),
                              overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 14,
                              ),
                              activeTrackColor: const Color(0xFFFC3C44),
                              inactiveTrackColor: Colors.white.withOpacity(0.1),
                              thumbColor: Colors.white,
                            ),
                            child: Slider(
                              value: pos.inMilliseconds.toDouble().clamp(
                                0.0,
                                dur.inMilliseconds.toDouble() > 0
                                    ? dur.inMilliseconds.toDouble()
                                    : 0.0,
                              ),
                              max: dur.inMilliseconds.toDouble() > 0
                                  ? dur.inMilliseconds.toDouble()
                                  : 1.0,
                              onChanged: (v) => _musicService.seekTo(
                                Duration(milliseconds: v.toInt()),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatDuration(pos),
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  _formatDuration(dur),
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // --- CONTROLS ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.shuffle, color: Colors.white54),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.skip_previous_rounded,
                          size: 45,
                          color: Colors.white,
                        ),
                        onPressed: () => _musicService.skipPrevious(),
                      ),
                      _buildPlayPauseButton(),
                      IconButton(
                        icon: const Icon(
                          Icons.skip_next_rounded,
                          size: 45,
                          color: Colors.white,
                        ),
                        onPressed: () => _musicService.skipNext(),
                      ),
                      IconButton(
                        icon: const Icon(Icons.repeat, color: Colors.white54),
                        onPressed: () {},
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayPauseButton() {
    return StreamBuilder<PlayerState>(
      stream: _musicService.audioPlayer.playerStateStream,
      builder: (context, snapshot) {
        final playing = snapshot.data?.playing ?? false;
        return GestureDetector(
          onTap: () => playing
              ? _musicService.audioPlayer.pause()
              : _musicService.audioPlayer.play(),
          child: Container(
            height: 80,
            width: 80,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
              size: 50,
              color: Colors.black,
            ),
          ),
        );
      },
    );
  }
}
