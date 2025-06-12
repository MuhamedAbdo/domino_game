import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'game_screen.dart';
import 'results_screen.dart';
import 'players_setup_screen.dart';
import 'package:hive/hive.dart';
import '../models/player.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onTabSelected(int idx) {
    setState(() {
      _selectedIndex = idx;
    });
  }

  final List<Widget> _pages = [
    GameScreen(key: ValueKey('game')),
    ResultsScreen(key: ValueKey('results')),
  ];

  Future<bool> _onWillPop() async {
    if (_selectedIndex == 1) {
      setState(() {
        _selectedIndex = 0;
      });
      return false;
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PlayersSetupScreen()),
      );
      return false;
    }
  }

  void _continuePreviousGame() {
    setState(() {
      _selectedIndex = 0;
    });
  }

  void _startNewGame() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const PlayersSetupScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final playerBox = Hive.box<Player>('players');
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'لعبة الدومينو',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => _onTabSelected(0),
              child: Text(
                "اللعبة",
                style: TextStyle(
                  color: _selectedIndex == 0 ? Colors.yellow : Colors.white,
                  fontWeight:
                      _selectedIndex == 0 ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            TextButton(
              onPressed: () => _onTabSelected(1),
              child: Text(
                "النتائج",
                style: TextStyle(
                  color: _selectedIndex == 1 ? Colors.yellow : Colors.white,
                  fontWeight:
                      _selectedIndex == 1 ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
        body: ValueListenableBuilder(
          valueListenable: playerBox.listenable(),
          builder: (context, Box<Player> box, _) {
            final hasOngoingGame =
                box.isNotEmpty && box.values.any((p) => p.score > 0);

            return Column(
              children: [
                if (hasOngoingGame)
                  Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 4),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        minimumSize: const Size(180, 48),
                      ),
                      onPressed: _continuePreviousGame,
                      icon: const Icon(Icons.play_arrow, color: Colors.white),
                      label: const Text(
                        "متابعة اللعبة الجارية",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 4),
                    child: Text(
                      "لا توجد مباراة جارية حالياً",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                Expanded(
                  child: _pages[_selectedIndex],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
