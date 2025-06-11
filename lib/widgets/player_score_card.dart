import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:domino_game/models/player.dart';

class PlayerScoreCard extends StatelessWidget {
  final int playerIndex;

  const PlayerScoreCard({Key? key, required this.playerIndex})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<Player>>(
      valueListenable: Hive.box<Player>('players').listenable(),
      builder: (context, box, _) {
        final player = box.getAt(playerIndex);
        return Card(
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  player?.name ?? 'لاعب $playerIndex',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  'النقاط: ${player?.score ?? 0}',
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
