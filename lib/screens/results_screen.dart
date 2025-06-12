import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:domino_game/models/game_result.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'game_screen.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({Key? key}) : super(key: key);

  Future<bool> _onWillPop(BuildContext context) async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const GameScreen()),
    );
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            'نتائج الألعاب',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        body: ValueListenableBuilder<Box<GameResult>>(
          valueListenable: Hive.box<GameResult>('results').listenable(),
          builder: (context, box, _) {
            final results = box.values.toList().reversed.toList();

            if (results.isEmpty) {
              return const Center(
                child: Text('لا توجد نتائج مسجلة بعد'),
              );
            }

            return ListView.builder(
              itemCount: results.length,
              itemBuilder: (context, index) {
                final result = results[index];
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: MediaQuery.of(context).size.width,
                    ),
                    child: Slidable(
                      endActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (_) =>
                                _deleteResult(context, box, result),
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                            label: 'حذف',
                          ),
                        ],
                      ),
                      child: Card(
                        elevation: 3,
                        margin: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'التاريخ: ${_formatDate(result.date)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                for (final player in result.players)
                                  Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    child: Text(
                                      '${player.name}: ${player.score}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: player.name == result.winner
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: player.name == result.winner
                                            ? Colors.green
                                            : Colors.black,
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 8),
                                Text(
                                  'الفائز: ${result.winner}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }

  void _deleteResult(
      BuildContext context, Box<GameResult> box, GameResult result) {
    final key = result.key;
    if (key != null) {
      box.delete(key);
    }
  }
}
