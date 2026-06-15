import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/models/game_entities.dart';
import 'database_provider.dart';

final historyProvider = FutureProvider<List<GameWithPlayers>>((ref) async {
  final db = ref.read(databaseProvider);
  return db.loadAllGames();
});
