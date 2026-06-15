import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../core/database/app_database.dart';
import '../core/models/game_entities.dart';
import '../core/models/wind.dart';
import '../core/models/tile.dart';
import '../core/scoring/hand_scorer.dart';
import '../core/scoring/point_distributor.dart';
import 'database_provider.dart';

const _uuid = Uuid();

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final gameProvider =
    StateNotifierProvider<GameNotifier, AsyncValue<GameWithPlayers?>>(
  (ref) => GameNotifier(ref.read(databaseProvider)),
);

// ---------------------------------------------------------------------------
// State notifier
// ---------------------------------------------------------------------------

class GameNotifier extends StateNotifier<AsyncValue<GameWithPlayers?>> {
  GameNotifier(this._db) : super(const AsyncValue.loading()) {
    _loadActiveGame();
  }

  final AppDatabase _db;

  Future<void> _loadActiveGame() async {
    state = const AsyncValue.loading();
    try {
      final game = await _db.getLatestInProgressGame();
      if (game == null) {
        state = const AsyncValue.data(null);
      } else {
        final full = await _db.loadFullGame(game.id);
        state = AsyncValue.data(full);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // ---- Create a new game ----

  Future<void> startNewGame({
    required List<String> playerNames,
  }) async {
    final gameId = _uuid.v4();
    final now = DateTime.now();

    final game = Game(
      id: gameId,
      startedAt: now,
      status: GameStatus.inProgress,
    );
    await _db.insertGame(game);

    final winds = [Wind.est, Wind.sud, Wind.ouest, Wind.nord];
    final gamePlayers = <GamePlayer>[];

    for (var i = 0; i < 4; i++) {
      final name = playerNames[i].trim();

      // Reuse existing player or create a new one
      final allPlayers = await _db.getAllPlayers();
      final existing = allPlayers
          .where((p) => p.name.toLowerCase() == name.toLowerCase())
          .firstOrNull;

      final playerId = existing?.id ?? _uuid.v4();
      if (existing == null) {
        await _db.upsertPlayer(
          Player(id: playerId, name: name, createdAt: now),
        );
      }

      final gp = GamePlayer(
        id: _uuid.v4(),
        gameId: gameId,
        playerId: playerId,
        playerName: name,
        position: i,
        startingWind: winds[i],
      );
      await _db.insertGamePlayer(gp);
      gamePlayers.add(gp);
    }

    final full = GameWithPlayers(game: game, players: gamePlayers, turns: []);
    state = AsyncValue.data(full);
  }

  // ---- Add a completed turn ----

  Future<void> addTurn({
    required Wind dominantWind,
    required List<TurnPlayerInput> playerInputs,
  }) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final turnNumber = current.turns.length + 1;
    final turnId = _uuid.v4();
    final now = DateTime.now();

    // Compute current wind for each player (based on turn count)
    final turnIndex = turnNumber - 1; // 0-based

    final scoreInputs = playerInputs.map((pi) {
      final gp = current.players.firstWhere((p) => p.id == pi.gamePlayerId);
      return PlayerScoreInput(
        gamePlayerId: gp.id,
        playerName: gp.playerName,
        currentWind: gp.windAtTurn(turnIndex),
        handScore: pi.handScore,
        isMahjong: pi.isMahjong,
      );
    }).toList();

    final distribution = PointDistributor.distribute(scoreInputs);

    // Persist turn
    final turn = Turn(
      id: turnId,
      gameId: current.game.id,
      turnNumber: turnNumber,
      dominantWind: dominantWind,
      createdAt: now,
    );
    await _db.insertTurn(turn);

    final playerTurns = <PlayerTurn>[];
    for (final pi in playerInputs) {
      final gp = current.players.firstWhere((p) => p.id == pi.gamePlayerId);
      final wind = gp.windAtTurn(turnIndex);

      final tileJson = pi.tiles.isNotEmpty
          ? jsonEncode(pi.tiles
              .map((t) => {'id': t.tile.id, 'exposed': t.exposed})
              .toList())
          : null;

      final pt = PlayerTurn(
        id: _uuid.v4(),
        turnId: turnId,
        gamePlayerId: pi.gamePlayerId,
        playerId: gp.playerId,
        currentWind: wind,
        handScore: pi.handScore,
        netGain: distribution.netGains[pi.gamePlayerId] ?? 0,
        isMahjong: pi.isMahjong,
        grandJeuName: pi.grandJeuName,
        specialFlags: pi.handInput?.specialFlags ?? [],
        tileDataJson: tileJson,
      );
      await _db.insertPlayerTurn(pt);
      playerTurns.add(pt);
    }

    final newTurnWithResults =
        TurnWithResults(turn: turn, playerTurns: playerTurns);
    final updatedTurns = [...current.turns, newTurnWithResults];

    state = AsyncValue.data(GameWithPlayers(
        game: current.game, players: current.players, turns: updatedTurns));
  }

  // ---- End current game ----

  Future<void> endGame() async {
    final current = state.valueOrNull;
    if (current == null) return;

    final completed = current.game.copyWith(
      status: GameStatus.completed,
      completedAt: DateTime.now(),
    );
    await _db.updateGame(completed);
    state = const AsyncValue.data(null);
  }

  // ---- Reload from DB ----
  Future<void> reload() => _loadActiveGame();

  // ---- Resume an existing game ----
  Future<void> resumeGame(String gameId) async {
    final full = await _db.loadFullGame(gameId);
    state = AsyncValue.data(full);
  }
}

// ---------------------------------------------------------------------------
// Per-player input for a turn
// ---------------------------------------------------------------------------

class TurnPlayerInput {
  final String gamePlayerId;
  final int handScore;
  final bool isMahjong;
  final String? grandJeuName;
  final HandInput? handInput;
  final List<TileInstance> tiles;

  const TurnPlayerInput({
    required this.gamePlayerId,
    required this.handScore,
    required this.isMahjong,
    this.grandJeuName,
    this.handInput,
    this.tiles = const [],
  });
}
