import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/audio_controller.dart';
import 'screens/avatar_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AudioController(),
      child: MaterialApp(
        title: 'Avatar Lip Sync',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const AvatarScreen(),
      ),
    );
  }
}
