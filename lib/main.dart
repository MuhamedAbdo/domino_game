import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:domino_game/models/player.dart';
import 'screens/players_setup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(PlayerAdapter());
  await Hive.openBox<Player>('players');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'لعبة الدومينو',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const PlayersSetupScreen(),
    );
  }
}
