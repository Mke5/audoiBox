import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audiobox/music_service.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';

class MusicScreen extends StatefulWidget {
  const MusicScreen({super.key});
  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  final _musicService = MusicService();

  String _formatDuration(Duration d) {
    return "${d.inMinutes.remainder(60).toString().padLeft(2, '0')}:${d.inSeconds.remainder(60).toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final song = _musicService.currentSong;
    if (song == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F0F1A),
        body: Center(
          child: Text("No Song Playing", style: TextStyle(color: Colors.white)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Now Playing",
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Album Art
          // Center(
          //   child: Container(
          //     width: 280,
          //     height: 280,
          //     decoration: BoxDecoration(
          //       gradient: const LinearGradient(
          //         colors: [Colors.purple, Colors.deepPurple],
          //       ),
          //       borderRadius: BorderRadius.circular(20),
          //     ),
          //     child: const Icon(
          //       Icons.music_note,
          //       size: 100,
          //       color: Colors.white,
          //     ),
          //   ),
          // ),
          Center(
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: QueryArtworkWidget(
                  id: song.id, // The ID we stored in the model
                  type: ArtworkType.AUDIO,
                  artworkWidth: 280,
                  artworkHeight: 280,
                  artworkBorder: BorderRadius.circular(
                    0,
                  ), // Handled by ClipRRect
                  nullArtworkWidget: Container(
                    // Fallback if no image exists
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.purple, Colors.deepPurple],
                      ),
                    ),
                    child: const Icon(
                      Icons.music_note,
                      size: 100,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            song.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            song.artist,
            style: const TextStyle(color: Colors.white54, fontSize: 16),
          ),

          // Progress Slider
          StreamBuilder<Duration?>(
            stream: _musicService.audioPlayer.positionStream,
            builder: (context, snapshot) {
              final pos = snapshot.data ?? Duration.zero;
              final dur = _musicService.audioPlayer.duration ?? Duration.zero;
              return Column(
                children: [
                  Slider(
                    activeColor: Colors.purpleAccent,
                    // This is the magic line: clamp ensures value stays between 0.0 and duration
                    value: pos.inMilliseconds.toDouble().clamp(
                      0.0,
                      dur.inMilliseconds.toDouble() > 0
                          ? dur.inMilliseconds.toDouble()
                          : 0.0,
                    ),
                    max: dur.inMilliseconds.toDouble() > 0
                        ? dur.inMilliseconds.toDouble()
                        : 1.0,
                    onChanged: (v) =>
                        _musicService.seekTo(Duration(milliseconds: v.toInt())),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_formatDuration(pos)),
                        Text(_formatDuration(dur)),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),

          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // --- REPEAT BUTTON ---
              StreamBuilder<LoopMode>(
                stream: _musicService.audioPlayer.loopModeStream,
                builder: (context, snapshot) {
                  final loopMode = snapshot.data ?? LoopMode.off;
                  return IconButton(
                    icon: Icon(
                      loopMode == LoopMode.one
                          ? Icons.repeat_one
                          : Icons.repeat,
                      color: loopMode == LoopMode.off
                          ? Colors.white54
                          : Colors.purpleAccent,
                    ),
                    onPressed: () {
                      _musicService.audioPlayer.setLoopMode(
                        loopMode == LoopMode.off ? LoopMode.one : LoopMode.off,
                      );
                    },
                  );
                },
              ),

              IconButton(
                icon: const Icon(
                  Icons.skip_previous,
                  size: 40,
                  color: Colors.white,
                ),
                onPressed: () => setState(() => _musicService.skipPrevious()),
              ),

              _buildPlayPauseButton(),

              IconButton(
                icon: const Icon(
                  Icons.skip_next,
                  size: 40,
                  color: Colors.white,
                ),
                onPressed: () => setState(() => _musicService.skipNext()),
              ),

              // --- SHUFFLE BUTTON (Bonus for symmetry) ---
              StreamBuilder<bool>(
                stream: _musicService.audioPlayer.shuffleModeEnabledStream,
                builder: (context, snapshot) {
                  final isShuffle = snapshot.data ?? false;
                  return IconButton(
                    icon: Icon(
                      Icons.shuffle,
                      color: isShuffle ? Colors.purpleAccent : Colors.white54,
                    ),
                    onPressed: () => _musicService.audioPlayer
                        .setShuffleModeEnabled(!isShuffle),
                  );
                },
              ),
            ],
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
        return CircleAvatar(
          radius: 35,
          backgroundColor: Colors.purpleAccent,
          child: IconButton(
            icon: Icon(
              playing ? Icons.pause : Icons.play_arrow,
              size: 35,
              color: Colors.white,
            ),
            onPressed: () => _musicService.pauseSong(),
          ),
        );
      },
    );
  }
}
