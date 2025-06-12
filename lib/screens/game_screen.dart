import 'package:flutter/material.dart';
import 'package:domino_game/models/player.dart';
import 'package:domino_game/models/game_result.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'players_setup_screen.dart';
import 'results_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late Box<Player> playerBox;
  late Box<GameResult> resultsBox;
  List<TextEditingController> _scoreCtrls = [];
  final TextEditingController _targetScoreCtrl = TextEditingController();
  String winner = '';
  int targetScore = 101;
  bool resultSaved = false;

  @override
  void initState() {
    super.initState();
    playerBox = Hive.box<Player>('players');
    resultsBox = Hive.box<GameResult>('results');
    _targetScoreCtrl.text = targetScore.toString();

    _initControllers();
    _checkWinnerOnStart();
  }

  void _initControllers() {
    final count = playerBox.length;
    _scoreCtrls = List.generate(count, (_) => TextEditingController());
  }

  @override
  void dispose() {
    for (var c in _scoreCtrls) {
      c.dispose();
    }
    _targetScoreCtrl.dispose();
    super.dispose();
  }

  void _checkWinnerOnStart() {
    if (playerBox.length >= 2) {
      for (var i = 0; i < playerBox.length; i++) {
        if (playerBox.getAt(i)!.score >= targetScore) {
          winner = playerBox.getAt(i)!.name;
          return;
        }
      }
      winner = '';
    }
  }

  void _addScore(int index) {
    if (_getWinnerName() != null) return;
    final score = int.tryParse(_scoreCtrls[index].text);
    if (score == null || score <= 0) return;
    final player = playerBox.getAt(index)!;
    player.score += score;
    player.save();

    final currentWinner = _getWinnerName();
    if (currentWinner != null) {
      setState(() {
        winner = currentWinner;
      });
      _saveGameResult();
    }
    setState(() {
      _scoreCtrls[index].clear();
    });
  }

  void _saveGameResult() async {
    if (resultSaved || playerBox.length < 2) return;
    final winnerName = _getWinnerName();
    if (winnerName == null) return;
    final winnerPlayer =
        playerBox.values.firstWhere((p) => p.name == winnerName);

    final newResult = GameResult(
      players: playerBox.values.toList(),
      winner: winnerPlayer.name,
      date: DateTime.now(),
    );
    await resultsBox.add(newResult);
    setState(() {
      resultSaved = true;
    });
  }

  void _resetGame() async {
    for (int i = 0; i < playerBox.length; i++) {
      final p = playerBox.getAt(i)!;
      p.score = 0;
      await p.save();
    }
    setState(() {
      winner = '';
      resultSaved = false;
    });
  }

  void _changeNames() async {
    await playerBox.clear();
    setState(() {
      winner = '';
      resultSaved = false;
    });
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const PlayersSetupScreen()));
  }

  String? _getWinnerName() {
    for (var i = 0; i < playerBox.length; i++) {
      if (playerBox.getAt(i)!.score >= targetScore) {
        return playerBox.getAt(i)!.name;
      }
    }
    return null;
  }

  void _navigateToGameScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const GameScreen()),
    );
  }

  void _navigateToResultsScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => ResultsScreen()),
    );
  }

  Future<bool> _onWillPop() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const PlayersSetupScreen()),
    );
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'صفحة اللعبة',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          actions: [
            TextButton(
              onPressed: _navigateToGameScreen,
              child: const Text(
                "اللعبة",
                style: TextStyle(color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: _navigateToResultsScreen,
              child: const Text(
                "النتائج",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        body: ValueListenableBuilder(
          valueListenable: playerBox.listenable(),
          builder: (context, Box<Player> box, _) {
            if (box.isEmpty) {
              return const Center(child: Text('لا يوجد لاعبين!'));
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (winner.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.emoji_events, color: Colors.orange),
                          const SizedBox(width: 8),
                          Text(
                            'الفائز: $winner',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text(
                        'النقاط المستهدفة:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 60,
                        child: TextField(
                          controller: _targetScoreCtrl,
                          keyboardType: TextInputType.number,
                          enabled: winner.isEmpty,
                          onChanged: (val) {
                            final parsed = int.tryParse(val);
                            if (parsed != null && parsed > 0) {
                              setState(() {
                                targetScore = parsed;
                                _checkWinnerOnStart();
                              });
                            }
                          },
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 6),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: box.length,
                    itemBuilder: (ctx, idx) {
                      final player = box.getAt(idx)!;
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(
                            player.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('النقاط الحالية: ${player.score}'),
                          trailing: winner.isEmpty
                              ? SizedBox(
                                  width: 100,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: _scoreCtrls[idx],
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                            labelText: 'إضافة نقاط',
                                            isDense: true,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.add),
                                        color: Colors.blue,
                                        onPressed: () => _addScore(idx),
                                      ),
                                    ],
                                  ),
                                )
                              : null,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                        onPressed: _resetGame,
                        icon: const Icon(
                          Icons.refresh,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'إعادة تعيين النقاط',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: _changeNames,
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'تغيير الأسماء',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
