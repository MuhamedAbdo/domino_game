import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/player.dart';
import 'models/game_result.dart';
import 'screens/players_setup_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(PlayerAdapter());
  Hive.registerAdapter(GameResultAdapter());
  await Hive.openBox<Player>('players');
  await Hive.openBox<GameResult>('results');
  runApp(const MyApp());
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
          backgroundColor: Colors.blue,
          elevation: 4,
        ),
      ),
      home: const PlayersSetupScreen(),
    );
  }
}
