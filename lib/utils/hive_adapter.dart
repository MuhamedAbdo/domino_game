import 'package:flutter/material.dart';
import 'package:domino_game/screens/game_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHive(); // هنا يتم تهيئة Hive كاملة
  runApp(const MyApp());
}

Future<void> initHive() async {}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'لعبة الدومينو',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const GameScreen(),
    );
  }
}
