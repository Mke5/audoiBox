import 'package:audiobox/artist_detail_screen.dart';
import 'package:audiobox/music_service.dart';
import 'package:flutter/material.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';

class ArtistsScreen extends StatefulWidget {
  const ArtistsScreen({super.key});

  @override
  State<ArtistsScreen> createState() => _ArtistsScreenState();
}

class _ArtistsScreenState extends State<ArtistsScreen> {
  final MusicService _musicService = MusicService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [_buildAppBar(), _buildSearchBar(), _buildArtistList()],
      ),
    );
  }

  Widget _buildAppBar() {
    return const SliverAppBar(
      expandedHeight: 110.0,
      pinned: true,
      backgroundColor: Colors.black,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsetsDirectional.only(start: 16, bottom: 16),
        centerTitle: false,
        title: Text(
          "Artists",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: TextField(
          controller: _searchController,
          onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
          style: const TextStyle(color: Colors.white, fontSize: 16),
          cursorColor: const Color(0xFFFC3C44),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF1C1C1E),
            hintText: 'Find in artists',
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
            prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 22),
            contentPadding: EdgeInsets.zero,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildArtistList() {
    return FutureBuilder<List<ArtistModel>>(
      future: _musicService
          .queryArtists(), // Ensure this method exists in MusicService
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverFillRemaining(
            child: Center(
              child: CircularProgressIndicator(color: Color(0xFFFC3C44)),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SliverFillRemaining(
            child: Center(
              child: Text(
                "No artists found",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        // Filter based on search query
        final artists = snapshot.data!.where((artist) {
          return artist.artist.toLowerCase().contains(_searchQuery);
        }).toList();

        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 150),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final artist = artists[index];
              return Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundColor: const Color(0xFF1C1C1E),
                      child: QueryArtworkWidget(
                        id: artist.id,
                        type: ArtworkType.ARTIST,
                        // Changed nullItem to nullWidget
                        nullArtworkWidget: const Icon(
                          Icons.person,
                          color: Colors.grey,
                          size: 30,
                        ),
                      ),
                    ),
                    title: Text(
                      artist.artist,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      "${artist.numberOfTracks} songs • ${artist.numberOfAlbums} albums",
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: Colors.grey,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ArtistDetailScreen(
                            artistName: artist.artist,
                            artistId: artist.id,
                          ),
                        ),
                      );
                    },
                  ),
                  const Divider(color: Colors.white10, indent: 60),
                ],
              );
            }, childCount: artists.length),
          ),
        );
      },
    );
  }
}
