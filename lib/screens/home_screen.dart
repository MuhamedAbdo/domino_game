import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:domino_game/models/player.dart';
import 'package:domino_game/screens/game_screen.dart';
import 'package:domino_game/screens/results_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  // وظيفة للتحقق مما إذا كانت هناك لعبة قيد التشغيل
  Future<bool> _hasActiveGame() async {
    final box = Hive.box<Player>('players');
    return box.isNotEmpty && box.values.any((p) => p.score > 0);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _hasActiveGame(),
      builder: (context, snapshot) {
        final hasActiveGame = snapshot.data ?? false;

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('لعبة الدومينو'),
              bottom: const TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.gamepad), text: 'اللعبة'),
                  Tab(icon: Icon(Icons.leaderboard), text: 'النتائج'),
                ],
              ),
              actions: [
                if (hasActiveGame)
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: 'إعادة اللعبة',
                    onPressed: () {
                      // يمكنك هنا إعادة توجيه المستخدم أو تنفيذ وظيفة مباشرة
                      final playerBox = Hive.box<Player>('players');
                      for (var player in playerBox.values) {
                        player.score = 0;
                        player.save();
                      }
                      // يمكنك أيضًا إعادة بناء الشاشة أو إظهار رسالة
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم إعادة اللعبة')),
                      );
                    },
                  ),
              ],
            ),
            body: const TabBarView(
              children: [
                GameScreen(),
                ResultsScreen(),
              ],
            ),
          ),
        );
      },
    );
  }
}
