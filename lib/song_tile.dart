import 'package:audiobox/song_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SongTile extends StatelessWidget {
  final Song song;
  final bool isPlaying;
  final VoidCallback onTap;

  const SongTile({
    super.key,
    required this.song,
    required this.isPlaying,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isPlaying ? Colors.purple.withOpacity(0.2) : Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: isPlaying
            ? Border.all(color: Colors.deepPurple, width: 1)
            : null,
      ), // BoxDecoration
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isPlaying
                  ? [Colors.purple, Colors.purple.shade700]
                  : [Colors.grey[800]!, Colors.grey[700]!],
            ), // LinearGradient
          ), // BoxDecoration
          child: Icon(
            isPlaying ? Icons.music_note : Icons.music_note_outlined,
            color: Colors.white,
          ), // Icon
        ), // Container
        title: Text(
          song.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white,
            // fontSize: 16,
            fontWeight: isPlaying ? FontWeight.bold : FontWeight.normal,
          ), // TextStyle
        ), // Text
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              song.artist.isNotEmpty ? song.artist : "Unknown Artist",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 13,
              ), // TextStyle
            ), // Text
            if (song.duration.inSeconds > 0)
              Text(
                _formatDuration(song.duration),
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 11,
                ), // TextStyle
              ), // Text
          ],
        ), // subtitle
      ), // ListTile
    ); // Container
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitsMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitsSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitsMinutes:$twoDigitsSeconds";
  }
}
