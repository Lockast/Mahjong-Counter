import 'wind.dart';

// ---------------------------------------------------------------------------
// Player
// ---------------------------------------------------------------------------

class Player {
  final String id;
  final String name;
  final DateTime createdAt;

  const Player({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  Player copyWith({String? name}) =>
      Player(id: id, name: name ?? this.name, createdAt: createdAt);
}

// ---------------------------------------------------------------------------
// Game
// ---------------------------------------------------------------------------

enum GameStatus { inProgress, completed }

class Game {
  final String id;
  final DateTime startedAt;
  final DateTime? completedAt;
  final GameStatus status;

  const Game({
    required this.id,
    required this.startedAt,
    this.completedAt,
    required this.status,
  });

  Game copyWith({GameStatus? status, DateTime? completedAt}) => Game(
        id: id,
        startedAt: startedAt,
        completedAt: completedAt ?? this.completedAt,
        status: status ?? this.status,
      );
}

// ---------------------------------------------------------------------------
// GamePlayer — one seat in a game
// ---------------------------------------------------------------------------

class GamePlayer {
  final String id;
  final String gameId;
  final String playerId;
  final String playerName;
  final int position; // 0–3
  final Wind startingWind;

  const GamePlayer({
    required this.id,
    required this.gameId,
    required this.playerId,
    required this.playerName,
    required this.position,
    required this.startingWind,
  });

  /// The wind for this player given the number of turns already played.
  Wind windAtTurn(int turnIndex) {
    Wind w = startingWind;
    for (var i = 0; i < turnIndex; i++) {
      w = w.next;
    }
    return w;
  }
}

// ---------------------------------------------------------------------------
// Turn — one round of play
// ---------------------------------------------------------------------------

class Turn {
  final String id;
  final String gameId;
  final int turnNumber; // 1-based
  final Wind dominantWind;
  final DateTime createdAt;

  const Turn({
    required this.id,
    required this.gameId,
    required this.turnNumber,
    required this.dominantWind,
    required this.createdAt,
  });
}

// ---------------------------------------------------------------------------
// PlayerTurn — one player's result in one turn
// ---------------------------------------------------------------------------

class PlayerTurn {
  final String id;
  final String turnId;
  final String gamePlayerId;
  final String playerId;
  final Wind currentWind;
  final int handScore;
  final int netGain; // positive = won points, negative = lost points
  final bool isMahjong;
  final String? grandJeuName;
  final List<String> specialFlags; // e.g. ['tuileExposee', 'tuileDuMur']
  final String? tileDataJson; // JSON-encoded tile selection

  const PlayerTurn({
    required this.id,
    required this.turnId,
    required this.gamePlayerId,
    required this.playerId,
    required this.currentWind,
    required this.handScore,
    required this.netGain,
    required this.isMahjong,
    this.grandJeuName,
    this.specialFlags = const [],
    this.tileDataJson,
  });
}

// ---------------------------------------------------------------------------
// Composite view objects used by the UI
// ---------------------------------------------------------------------------

class GameWithPlayers {
  final Game game;
  final List<GamePlayer> players;
  final List<TurnWithResults> turns;

  const GameWithPlayers({
    required this.game,
    required this.players,
    required this.turns,
  });

  /// Running total score per gamePlayerId up to (and including) turnIndex.
  Map<String, int> totalsAtTurn(int turnIndex) {
    final map = <String, int>{for (final gp in players) gp.id: 0};
    for (var i = 0; i <= turnIndex && i < turns.length; i++) {
      for (final pt in turns[i].playerTurns) {
        map[pt.gamePlayerId] = (map[pt.gamePlayerId] ?? 0) + pt.netGain;
      }
    }
    return map;
  }

  Map<String, int> get totals => totalsAtTurn(turns.length - 1);
}

class TurnWithResults {
  final Turn turn;
  final List<PlayerTurn> playerTurns;

  const TurnWithResults({required this.turn, required this.playerTurns});

  PlayerTurn? mahjongResult() =>
      playerTurns.where((pt) => pt.isMahjong).firstOrNull;
}

// ---------------------------------------------------------------------------
// Player statistics aggregate
// ---------------------------------------------------------------------------

class PlayerStats {
  final Player player;
  final int gamesPlayed;
  final int firstPlaceCount;
  final int secondPlaceCount;
  final int thirdPlaceCount;
  final int fourthPlaceCount;
  final double meanFinalScore;
  final double medianFinalScore;
  final Map<String, int> grandJeuxAchieved; // name → count
  final bool hasEnoughTileData;

  const PlayerStats({
    required this.player,
    required this.gamesPlayed,
    required this.firstPlaceCount,
    required this.secondPlaceCount,
    required this.thirdPlaceCount,
    required this.fourthPlaceCount,
    required this.meanFinalScore,
    required this.medianFinalScore,
    required this.grandJeuxAchieved,
    required this.hasEnoughTileData,
  });

  double rankPct(int rank) {
    if (gamesPlayed == 0) return 0;
    return switch (rank) {
      1 => firstPlaceCount / gamesPlayed * 100,
      2 => secondPlaceCount / gamesPlayed * 100,
      3 => thirdPlaceCount / gamesPlayed * 100,
      4 => fourthPlaceCount / gamesPlayed * 100,
      _ => 0,
    };
  }
}
