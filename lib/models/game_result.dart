import 'package:hive/hive.dart';
import 'player.dart';

part 'game_result.g.dart';

@HiveType(typeId: 1)
class GameResult extends HiveObject {
  // أضف HiveObject هنا
  @HiveField(0)
  final List<Player> players;

  @HiveField(1)
  final String winner;

  @HiveField(2)
  final DateTime date;

  GameResult({
    required this.players,
    required this.winner,
    required this.date,
  });
}
