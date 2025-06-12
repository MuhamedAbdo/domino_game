import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:domino_game/models/player.dart';
import 'package:domino_game/models/game_result.dart';
import 'package:domino_game/screens/players_setup_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late Box<Player> playerBox;
  late Box<GameResult> resultsBox;
  final List<TextEditingController> _scoreCtrls = [];
  final TextEditingController _targetScoreCtrl = TextEditingController();
  String winner = '';
  int targetScore = 101;

  @override
  void initState() {
    super.initState();
    playerBox = Hive.box<Player>('players');
    resultsBox = Hive.box<GameResult>('game_results');
    _targetScoreCtrl.text = targetScore.toString();

    for (int i = 0; i < 4; i++) {
      _scoreCtrls.add(TextEditingController());
    }

    if (playerBox.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PlayersSetupScreen()),
        );
      });
    }
  }

  void _addScore(int index) {
    if (winner.isNotEmpty) return;
    final score = int.tryParse(_scoreCtrls[index].text);
    if (score == null || score <= 0) return;

    final player = playerBox.getAt(index)!;
    player.score += score;
    player.save();

    if (player.score >= targetScore) {
      setState(() {
        winner = player.name;
      });
      _saveGameResult();
    }
    _scoreCtrls[index].clear();
  }

  void _saveGameResult() {
    final players = playerBox.values.toList();
    final result = GameResult(
      players: players,
      winner: winner,
      date: DateTime.now(),
    );
    resultsBox.add(result);
  }

  void _resetGame() async {
    for (int i = 0; i < playerBox.length; i++) {
      final p = playerBox.getAt(i)!;
      p.score = 0;
      await p.save();
    }
    setState(() {
      winner = '';
    });
  }

  void _changeNames() async {
    await playerBox.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const PlayersSetupScreen()),
    );
  }

  void _updateTargetScore() {
    final val = int.tryParse(_targetScoreCtrl.text);
    if (val != null && val > 0) {
      setState(() {
        targetScore = val;
      });
    } else {
      _targetScoreCtrl.text = targetScore.toString();
    }
  }

  Widget _buildPlayerCard(int index, Player player) {
    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              player.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'النقاط: ${player.score}',
              style: const TextStyle(fontSize: 18),
            ),
            if (winner.isEmpty) ...[
              const SizedBox(height: 18),
              TextField(
                controller: _scoreCtrls[index],
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "أضف نقاط",
                  isDense: true,
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => _addScore(index),
                child: const Text("إضافة"),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // 📱 وظيفة التعامل مع زر العودة
  Future<bool> _onWillPop(BuildContext context) async {
    if (Navigator.of(context).canPop()) {
      return true; // يسمح بالرجوع إذا كان هناك شاشة سابقة
    }
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('تأكيد الخروج'),
            content: const Text('هل تريد الخروج إلى شاشة اختيار اللاعبين؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('إلغاء'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('تأكيد'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: ValueListenableBuilder<Box<Player>>(
        valueListenable: playerBox.listenable(),
        builder: (context, box, _) {
          final playerCount = box.length;
          if (playerCount == 0) {
            return const Center(child: CircularProgressIndicator());
          }

          return Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Text("نقطة", style: TextStyle(fontSize: 16)),
                      SizedBox(
                        width: 80,
                        child: TextField(
                          textAlign: TextAlign.center,
                          controller: _targetScoreCtrl,
                          keyboardType: TextInputType.number,
                          onSubmitted: (_) => _updateTargetScore(),
                          enabled: winner.isEmpty,
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 8,
                            ),
                          ),
                        ),
                      ),
                      const Text(
                        "النتيجة النهائية : ",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: playerCount <= 2
                        ? Row(
                            children: [
                              for (int i = 0; i < playerCount; i++)
                                Expanded(
                                  child: _buildPlayerCard(i, box.getAt(i)!),
                                ),
                            ],
                          )
                        : Column(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    for (int i = 0; i < 2; i++)
                                      Expanded(
                                        child:
                                            _buildPlayerCard(i, box.getAt(i)!),
                                      ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  children: [
                                    for (int i = 2; i < playerCount; i++)
                                      Expanded(
                                        child:
                                            _buildPlayerCard(i, box.getAt(i)!),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                  ),
                  if (winner.isNotEmpty) ...[
                    Text(
                      'مبروك $winner 🎉',
                      style: const TextStyle(
                        fontSize: 28,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _resetGame,
                          icon: const Icon(Icons.refresh),
                          label: const Text("إعادة اللعبة"),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed: _changeNames,
                          icon: const Icon(Icons.edit),
                          label: const Text("تغيير الأسماء"),
                        ),
                      ],
                    ),
                  ],
                  if (winner.isEmpty)
                    ElevatedButton.icon(
                      onPressed: _resetGame,
                      icon: const Icon(Icons.refresh),
                      label: const Text("إعادة اللعبة"),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
