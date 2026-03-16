import 'package:audiobox/main_navigation.dart';
import 'package:audiobox/music_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MusicService().initAudioSession();
  await _requestPermissions();
  runApp(const MyApp());
}

Future<void> _requestPermissions() async {
  // await [
  //   Permission.storage,
  //   Permission.manageExternalStorage,
  //   Permission.audio,
  // ].request();
  await Permission.audio.request();
  await Permission.storage.request();
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Audiobox',
      // home: ,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Color(0xFF0A0A0A),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF1A1A1A),
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: MainNavigation(),
    );
  }
}
