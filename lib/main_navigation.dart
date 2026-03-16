import 'dart:ui';
import 'package:audiobox/artists_screen.dart';
import 'package:audiobox/favorites_screen.dart';
import 'package:audiobox/playlists_screen.dart';
import 'package:flutter/material.dart';
import 'package:audiobox/home_screen.dart';
import 'package:audiobox/mini_player.dart';
import 'package:audiobox/music_service.dart';
import 'package:audiobox/music_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 2; // Start on 'Songs' (HomeScreen)
  final MusicService _musicService = MusicService();

  // The screens for each tab
  final List<Widget> _pages = [
    const FavoritesScreen(),
    const PlaylistsScreen(),
    const HomeScreen(), // Your actual content
    const ArtistsScreen(),
  ];

  void _openMusicScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MusicScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // This line forces the keyboard to hide and the cursor to stop blinking
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            IndexedStack(index: _selectedIndex, children: _pages),
            Positioned(
              left: 4,
              right: 4,
              bottom: 70, // Sits exactly above the tab bar
              child: StreamBuilder<int?>(
                stream: _musicService.audioPlayer.currentIndexStream,
                builder: (context, snapshot) {
                  if (snapshot.data == null) return const SizedBox.shrink();
                  return MiniPlayer(
                    onTap: () => _openMusicScreen(context),
                    onPlayPause: () => _musicService.pauseSong(),
                  );
                },
              ),
            ),

            // 3. Apple-Style Blurred Tab Bar
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildBlurredTabBar(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlurredTabBar() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            border: Border(
              top: BorderSide(color: Colors.white.withOpacity(0.1), width: 0.5),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            backgroundColor: Colors.transparent, // Required for blur to show
            type: BottomNavigationBarType.fixed,
            selectedItemColor: const Color(0xFFFC3C44),
            unselectedItemColor: Colors.grey,
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite),
                label: 'Favorites',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.playlist_play, size: 28),
                label: 'Playlists',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.music_note),
                label: 'Songs',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.people),
                label: 'Artists',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
