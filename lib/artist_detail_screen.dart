import 'package:flutter/material.dart';

class ArtistDetailScreen extends StatelessWidget {
  final String artistName;
  const ArtistDetailScreen({super.key, required this.artistName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFFC3C44)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(artistName, style: const TextStyle(color: Colors.white)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
        itemCount: 0, // Logic for ArtistTracksList goes here later
        itemBuilder: (context, index) {
          return const SizedBox.shrink();
        },
      ),
    ); // Scaffold
  }
}
