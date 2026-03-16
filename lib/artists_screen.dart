import 'package:audiobox/artist_detail_screen.dart';
import 'package:flutter/material.dart';

class ArtistsScreen extends StatefulWidget {
  const ArtistsScreen({super.key});

  @override
  State<ArtistsScreen> createState() => _ArtistsScreenState();
}

class _ArtistsScreenState extends State<ArtistsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  // Mock data for UI
  final List<Map<String, dynamic>> _artists = [
    {'name': 'The Weeknd', 'image': null},
    {'name': 'Taylor Swift', 'image': null},
    {'name': 'Daft Punk', 'image': null},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 110.0,
            floating: false,
            pinned: true,
            backgroundColor: Colors.black,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsetsDirectional.only(
                start: 16,
                bottom: 16,
              ),
              centerTitle: false,
              title: Text(
                "Artists",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ), // TextStyle
              ), // Text
            ), // FlexibleSpacebar
          ), // SilverAppBar
          // Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val),
                style: const TextStyle(color: Colors.white, fontSize: 16),
                cursorColor: const Color(0xFFFC3C44),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF1C1C1E),
                  hintText: 'Find in artists',
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.grey,
                    size: 22,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ), // InputDecoration
              ), // TextField
            ), // Padding
          ), // SliverToBoxAdapter
          // Artist List
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 150),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final artist = _artists[index];
                return Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey[900],
                        child: const Icon(Icons.person, color: Colors.grey),
                      ),
                      title: Text(
                        artist['name'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: Colors.grey,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ArtistDetailScreen(artistName: artist['name']),
                          ),
                        );
                      },
                    ),
                    const Divider(color: Colors.white10, indent: 50),
                  ],
                ); // Column
              }, childCount: _artists.length),
            ), // SliverList
          ), // SliverPadding
        ],
      ), // CustomScrollView
    );
  }
}
