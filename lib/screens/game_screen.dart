import 'package:flutter/material.dart';
import 'package:domino_game/models/player.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'players_setup_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late Box<Player> playerBox;
  final List<TextEditingController> _scoreCtrls = [
    TextEditingController(),
    TextEditingController(),
  ];
  final TextEditingController _targetScoreCtrl = TextEditingController();
  String winner = '';
  int targetScore = 101;

  @override
  void initState() {
    super.initState();
    playerBox = Hive.box<Player>('players');
    if (playerBox.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const PlayersSetupScreen()));
      });
    }
    _targetScoreCtrl.text = targetScore.toString();
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
    }
    setState(() {
      _scoreCtrls[index].clear();
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
    });
  }

  void _changeNames() async {
    await playerBox.clear();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const PlayersSetupScreen()));
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

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<Player>>(
      valueListenable: playerBox.listenable(),
      builder: (context, box, _) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text('لعبة الدومينو'),
            actions: [
              if (winner.isNotEmpty)
                IconButton(
                  onPressed: _changeNames,
                  icon: const Icon(Icons.edit),
                  tooltip: 'تغيير أسماء اللاعبين',
                ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Text(
                      " نقطة",
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(
                      width: 80,
                      child: TextField(
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.center,
                        controller: _targetScoreCtrl,
                        keyboardType: TextInputType.number,
                        onSubmitted: (_) => _updateTargetScore(),
                        onEditingComplete: _updateTargetScore,
                        enabled: winner.isEmpty,
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                        ),
                      ),
                    ),
                    const Text(
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                      "النتيجة النهائية : ",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: Row(
                    children: List.generate(2, (i) {
                      final player = box.getAt(i);
                      return Expanded(
                        child: Card(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          elevation: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  player?.name ?? 'لاعب ${i + 1}',
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'النقاط: ${player?.score ?? 0}',
                                  style: const TextStyle(fontSize: 18),
                                ),
                                const SizedBox(height: 18),
                                if (winner.isEmpty)
                                  Column(
                                    children: [
                                      TextField(
                                        controller: _scoreCtrls[i],
                                        keyboardType: TextInputType.number,
                                        enabled: winner.isEmpty,
                                        decoration: InputDecoration(
                                          labelText: "أضف نقاط",
                                          isDense: true,
                                          border: const OutlineInputBorder(),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 8),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      ElevatedButton(
                                        onPressed: winner.isEmpty
                                            ? () => _addScore(i)
                                            : null,
                                        child: const Text("إضافة"),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                if (winner.isNotEmpty)
                  Column(
                    children: [
                      Text(
                        'مبروك $winner 🎉',
                        style: const TextStyle(
                          fontSize: 28,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: _resetGame,
                        icon: const Icon(Icons.refresh),
                        label: const Text("إعادة اللعبة"),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: _changeNames,
                        icon: const Icon(Icons.edit),
                        label: const Text("تغيير أسماء اللاعبين"),
                      ),
                    ],
                  ),
                if (winner.isEmpty)
                  ElevatedButton.icon(
                    onPressed: _resetGame,
                    icon: const Icon(Icons.refresh),
                    label: const Text("إعادة اللعبة"),
                  ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }
}
