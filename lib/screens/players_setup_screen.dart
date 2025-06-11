import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:domino_game/models/player.dart';
import 'game_screen.dart';

class PlayersSetupScreen extends StatefulWidget {
  const PlayersSetupScreen({Key? key}) : super(key: key);

  @override
  State<PlayersSetupScreen> createState() => _PlayersSetupScreenState();
}

class _PlayersSetupScreenState extends State<PlayersSetupScreen> {
  final TextEditingController player1Ctrl = TextEditingController();
  final TextEditingController player2Ctrl = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  String? error;

  Future<void> _startGame() async {
    if (_formKey.currentState!.validate()) {
      // امسح اللاعبين السابقين
      final box = Hive.box<Player>('players');
      await box.clear();
      await box.add(Player(name: player1Ctrl.text.trim(), score: 0));
      await box.add(Player(name: player2Ctrl.text.trim(), score: 0));

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const GameScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'إدخال أسماء اللاعبين',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                controller: player1Ctrl,
                decoration: const InputDecoration(
                  labelText: 'اسم اللاعب 1',
                  hintText: 'أدخل اسم اللاعب الأول',
                  hintTextDirection: TextDirection.rtl,
                  floatingLabelAlignment: FloatingLabelAlignment.start,
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'أدخل اسم اللاعب 1' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                controller: player2Ctrl,
                decoration: const InputDecoration(
                  labelText: 'اسم اللاعب 2',
                  hintText: 'أدخل اسم اللاعب الثاني',
                  hintTextDirection: TextDirection.rtl,
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'أدخل اسم اللاعب 2' : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _startGame,
                child: const Text('بدء اللعبة'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
