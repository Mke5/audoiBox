// import 'package:audiobox/song_model.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';

// class SongTile extends StatelessWidget {
//   final Song song;
//   final bool isPlaying;
//   final VoidCallback onTap;

//   const SongTile({
//     super.key,
//     required this.song,
//     required this.isPlaying,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: EdgeInsets.only(bottom: 12),
//       decoration: BoxDecoration(
//         color: isPlaying ? Colors.purple.withOpacity(0.2) : Color(0xFF1A1A1A),
//         borderRadius: BorderRadius.circular(12),
//         border: isPlaying
//             ? Border.all(color: Colors.deepPurple, width: 1)
//             : null,
//       ), // BoxDecoration
//       child: ListTile(
//         contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         leading: Container(
//           height: 50,
//           width: 50,
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: isPlaying
//                   ? [Colors.purple, Colors.purple.shade700]
//                   : [Colors.grey[800]!, Colors.grey[700]!],
//             ), // LinearGradient
//           ), // BoxDecoration
//           child: Icon(
//             isPlaying ? Icons.music_note : Icons.music_note_outlined,
//             color: Colors.white,
//           ), // Icon
//         ), // Container
//         title: Text(
//           song.title,
//           maxLines: 1,
//           overflow: TextOverflow.ellipsis,
//           style: TextStyle(
//             color: Colors.white,
//             // fontSize: 16,
//             fontWeight: isPlaying ? FontWeight.bold : FontWeight.normal,
//           ), // TextStyle
//         ), // Text
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               song.artist.isNotEmpty ? song.artist : "Unknown Artist",
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//               style: TextStyle(
//                 color: Colors.grey[400],
//                 fontSize: 13,
//               ), // TextStyle
//             ), // Text
//             if (song.duration.inSeconds > 0)
//               Text(
//                 _formatDuration(song.duration),
//                 style: TextStyle(
//                   color: Colors.grey[500],
//                   fontSize: 11,
//                 ), // TextStyle
//               ), // Text
//           ],
//         ), // subtitle
//         trailing: isPlaying
//             ? Container(
//                 padding: EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: Colors.deepPurple.withOpacity(0.2),
//                   shape: BoxShape.circle,
//                 ), // BoxDecoration
//                 child: Icon(Icons.pause, color: Colors.deepPurple, size: 20),
//               ) // Container
//             : Icon(Icons.play_arrow, color: Colors.grey[600]),
//         onTap: onTap,
//       ), // ListTile
//     ); // Container
//   }

//   String _formatDuration(Duration duration) {
//     String twoDigits(int n) => n.toString().padLeft(2, '0');
//     String twoDigitsMinutes = twoDigits(duration.inMinutes.remainder(60));
//     String twoDigitsSeconds = twoDigits(duration.inSeconds.remainder(60));
//     return "$twoDigitsMinutes:$twoDigitsSeconds";
//   }
// }
//
//
//

// import 'package:audiobox/song_model.dart';
// import 'package:flutter/material.dart';
// import 'package:on_audio_query_pluse/on_audio_query.dart';

// class SongTile extends StatelessWidget {
//   final Song song;
//   final bool isPlaying;
//   final VoidCallback onTap;

//   const SongTile({
//     super.key,
//     required this.song,
//     required this.isPlaying,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       decoration: BoxDecoration(
//         color: isPlaying ? const Color(0xFF1C1C1E) : const Color(0xFF121212),
//         borderRadius: BorderRadius.circular(12),
//         border: isPlaying
//           ? Border.all(color: const Color(0xFFFC3C44), width: 1.5) // colors.primary
//           : Border.all(color: Colors.white.withOpacity(0.05), width: 1),
//       ),
//       child: ListTile(
//         contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         leading: Container(
//           height: 50,
//           width: 50,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(
//               8,
//             ), // Keeps your internal rounding
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: isPlaying
//                   ? [Colors.purple, Colors.purple.shade700]
//                   : [Colors.grey[800]!, Colors.grey[700]!],
//             ),
//           ),
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(8),
//             child: QueryArtworkWidget(
//               id: song.id,
//               type: ArtworkType.AUDIO,
//               nullArtworkWidget: Icon(
//                 isPlaying ? Icons.music_note : Icons.music_note_outlined,
//                 color: isPlaying ? const Color(0xFFFC3C44) : Colors.white54,
//                 size: 30,
//               ),
//             ),
//           ),
//         ),
//         title: Text(
//           song.title,
//           maxLines: 1,
//           overflow: TextOverflow.ellipsis,
//           style: TextStyle(
//             color: isPlaying ? const Color(0xFFFC3C44) : const Color(0xFFFFFFFF),
//             fontSize: 16,
//             fontWeight: isPlaying ? FontWeight.bold : FontWeight.w500,
//           ),
//         ),
//         // subtitle: Column(
//         //   crossAxisAlignment: CrossAxisAlignment.start,
//         //   children: [
//         //     Text(
//         //       song.artist.isNotEmpty ? song.artist : "Unknown Artist",
//         //       maxLines: 1,
//         //       overflow: TextOverflow.ellipsis,
//         //       style: TextStyle(color: Colors.grey[400], fontSize: 13),
//         //     ),
//         //     if (song.duration.inSeconds > 0)
//         //       Text(
//         //         _formatDuration(song.duration),
//         //         style: TextStyle(color: Colors.grey[500], fontSize: 11),
//         //       ),
//         //   ],
//         // ),
//         subtitle: Text(
//           song.artist.isNotEmpty ? song.artist : "Unknown Artist",
//           maxLines: 1,
//           overflow: TextOverflow.ellipsis,
//           style: const TextStyle(
//             color: Color(0xFF9CA3AF), // colors.textMuted
//             fontSize: 12, // fontSize.xs
//           ),
//         ),
//         // trailing: isPlaying
//         //     ? Container(
//         //         padding: const EdgeInsets.all(8),
//         //         decoration: BoxDecoration(
//         //           color: Colors.deepPurple.withOpacity(0.2),
//         //           shape: BoxShape.circle,
//         //         ),
//         //         child: const Icon(
//         //           Icons.pause,
//         //           color: Colors.deepPurple,
//         //           size: 20,
//         //         ),
//         //       )
//         //     : Icon(Icons.play_arrow, color: Colors.grey[600]),
//         trailing: isPlaying
//           ? const Icon(Icons.volume_up, color: Color(0xFFFC3C44), size: 20)
//           : const Icon(Icons.play_arrow_rounded, color: Color(0xFF9CA3AF)),
//         onTap: onTap,
//       ),
//     );
//   }

//   String _formatDuration(Duration duration) {
//     String twoDigits(int n) => n.toString().padLeft(2, '0');
//     String twoDigitsMinutes = twoDigits(duration.inMinutes.remainder(60));
//     String twoDigitsSeconds = twoDigits(duration.inSeconds.remainder(60));
//     return "$twoDigitsMinutes:$twoDigitsSeconds";
//   }
// }

import 'package:audiobox/song_model.dart';
import 'package:flutter/material.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';

class SongTile extends StatelessWidget {
  final Song song;
  final bool isPlaying;
  final bool isActuallyPlaying; // Add this to check if music isn't paused
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
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0),
      child: InkWell(
        // Use InkWell for that "TouchableHighlight" feel
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              // --- ARTWORK WITH OVERLAY INDICATOR ---
              Stack(
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
                          child: const Icon(
                            Icons.music_note,
                            color: Colors.white54,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Show indicator only if this track is the active one
                  if (isPlaying)
                    isActuallyPlaying
                        ? const Icon(
                            Icons.bar_chart_rounded,
                            color: Colors.white,
                            size: 24,
                          )
                        : const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                ],
              ),
              const SizedBox(width: 14),

              // --- TITLE AND ARTIST ---
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isPlaying
                            ? const Color(0xFFFC3C44)
                            : Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      song.artist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF9CA3AF), // textMuted
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {},
                // --- THREE DOTS MENU ---
                child: PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert,
                    color: Colors.white,
                    size: 20,
                  ),
                  color: const Color(
                    0xFF1C1C1E,
                  ), // Matches your secondary dark color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: (value) {
                    if (value == 'share') {
                      // Logic for sharing
                    } else if (value == 'delete') {
                      // Logic for deleting
                    }
                  },
                  itemBuilder: (BuildContext context) => [
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
