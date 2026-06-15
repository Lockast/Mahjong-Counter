import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/database/app_database.dart';
import '../core/models/game_entities.dart';
import 'database_provider.dart';

final allPlayersStatsProvider = FutureProvider<List<PlayerStats>>((ref) async {
  final db = ref.read(databaseProvider);
  final players = await db.getAllPlayers();
  final allGames = await db.loadAllGames();

  final stats = <PlayerStats>[];
  for (final player in players) {
    final stat = await _buildStats(player, allGames, db);
    if (stat != null) stats.add(stat);
  }
  return stats;
});

Future<PlayerStats?> _buildStats(
  Player player,
  List<GameWithPlayers> allGames,
  AppDatabase db,
) async {
  // Only games where this player participated
  final playerGames = allGames.where((g) {
    return g.players.any((gp) => gp.playerId == player.id);
  }).toList();

  if (playerGames.isEmpty) return null;

  int first = 0, second = 0, third = 0, fourth = 0;
  final finalScores = <int>[];
  final grandJeux = <String, int>{};

  for (final game in playerGames) {
    if (game.game.status != GameStatus.completed) continue;

    final gp = game.players.firstWhereOrNull((p) => p.playerId == player.id);
    if (gp == null) continue;

    final totals = game.totals;
    final sortedTotals = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final rank = sortedTotals.indexWhere((e) => e.key == gp.id) + 1;
    switch (rank) {
      case 1:
        first++;
      case 2:
        second++;
      case 3:
        third++;
      case 4:
        fourth++;
    }

    finalScores.add(totals[gp.id] ?? 0);

    // Count Grand Jeux
    for (final turn in game.turns) {
      for (final pt in turn.playerTurns) {
        if (pt.playerId == player.id && pt.grandJeuName != null) {
          grandJeux[pt.grandJeuName!] = (grandJeux[pt.grandJeuName!] ?? 0) + 1;
        }
      }
    }
  }

  final completedGames =
      playerGames.where((g) => g.game.status == GameStatus.completed).length;

  double mean = 0;
  double median = 0;
  if (finalScores.isNotEmpty) {
    mean = finalScores.reduce((a, b) => a + b) / finalScores.length;
    final sorted = List<int>.from(finalScores)..sort();
    final mid = sorted.length ~/ 2;
    median = sorted.length.isOdd
        ? sorted[mid].toDouble()
        : (sorted[mid - 1] + sorted[mid]) / 2.0;
  }

  // Check tile data availability (> 5 games with tile data)
  final allPt = await db.getPlayerTurnsForPlayer(player.id);
  final tileDataCount = allPt.where((pt) => pt.tileDataJson != null).length;

  return PlayerStats(
    player: player,
    gamesPlayed: completedGames,
    firstPlaceCount: first,
    secondPlaceCount: second,
    thirdPlaceCount: third,
    fourthPlaceCount: fourth,
    meanFinalScore: mean,
    medianFinalScore: median,
    grandJeuxAchieved: grandJeux,
    hasEnoughTileData: tileDataCount >= 5,
  );
}
