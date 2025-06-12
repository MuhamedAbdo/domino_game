import 'package:flutter/material.dart';
import 'package:domino_game/screens/home_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:domino_game/models/player.dart';
import 'package:domino_game/models/game_result.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Hive.initFlutter();
    await _initHive();
    runApp(const MyApp());
  } catch (e) {
    print('Error initializing Hive: $e');
    await Hive.deleteBoxFromDisk('players');
    await Hive.deleteBoxFromDisk('game_results');
    await _initHive();
    runApp(const MyApp());
  }
}

Future<void> _initHive() async {
  Hive.registerAdapter(PlayerAdapter());
  Hive.registerAdapter(GameResultAdapter());
  await Hive.openBox<Player>('players');
  await Hive.openBox<GameResult>('game_results');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'لعبة الدومينو',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
