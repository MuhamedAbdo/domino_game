import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:domino_game/models/player.dart';
import 'package:domino_game/screens/game_screen.dart';

class PlayersSetupScreen extends StatefulWidget {
  const PlayersSetupScreen({Key? key}) : super(key: key);

  @override
  State<PlayersSetupScreen> createState() => _PlayersSetupScreenState();
}

class _PlayersSetupScreenState extends State<PlayersSetupScreen> {
  final List<TextEditingController> _playerCtrls = [];
  int playerCount = 2;
  bool _hasActiveGame = false;

  @override
  void initState() {
    super.initState();
    _initControllers();
    _checkActiveGame();
  }

  void _initControllers() {
    _playerCtrls.clear();
    for (int i = 0; i < 4; i++) {
      _playerCtrls.add(TextEditingController());
    }
  }

  Future<void> _checkActiveGame() async {
    final box = Hive.box<Player>('players');
    setState(() {
      _hasActiveGame = box.isNotEmpty && box.values.any((p) => p.score > 0);
    });
  }

  Future<bool> _onWillPop() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('تأكيد الخروج'),
            content: const Text(
                'هل أنت متأكد أنك تريد الخروج؟ سيتم فقدان البيانات الحالية.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('إلغاء'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('خروج'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _continueGame() async {
    final box = Hive.box<Player>('players');
    if (box.isEmpty || box.values.every((p) => p.score == 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يوجد مباراة حالية')),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const GameScreen()),
      );
    }
  }

  Future<void> _startNewGame() async {
    final box = Hive.box<Player>('players');
    await box.clear();
    for (int i = 0; i < playerCount; i++) {
      await box.add(Player(
        name: _playerCtrls[i].text.trim(),
        score: 0,
      ));
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const GameScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إعداد اللاعبين'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              if (_hasActiveGame)
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: _continueGame,
                      child: const Text('استكمال المباراة الحالية'),
                    ),
                    const SizedBox(height: 20),
                    const Text('أو', style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 20),
                  ],
                ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      DropdownButtonFormField<int>(
                        value: playerCount,
                        items: const [
                          DropdownMenuItem(value: 2, child: Text('2 لاعبين')),
                          DropdownMenuItem(value: 3, child: Text('3 لاعبين')),
                          DropdownMenuItem(value: 4, child: Text('4 لاعبين')),
                        ],
                        onChanged: (value) =>
                            setState(() => playerCount = value!),
                        decoration: const InputDecoration(
                          labelText: 'عدد اللاعبين',
                        ),
                      ),
                      const SizedBox(height: 20),
                      ...List.generate(playerCount, (index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: TextFormField(
                            controller: _playerCtrls[index],
                            decoration: InputDecoration(
                              labelText: 'اسم اللاعب ${index + 1}',
                              hintText: 'أدخل اسم اللاعب',
                            ),
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'أدخل اسم اللاعب'
                                : null,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: _startNewGame,
                child: const Text('بدء مباراة جديدة'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
