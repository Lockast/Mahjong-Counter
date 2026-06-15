import 'dart:convert';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/game_entities.dart';
import '../models/wind.dart';

class AppDatabase {
  Database? _db;

  Future<void> init() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'mahjong.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Database get db {
    assert(_db != null, 'AppDatabase.init() must be called before use');
    return _db!;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE players (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE games (
        id TEXT PRIMARY KEY,
        started_at INTEGER NOT NULL,
        completed_at INTEGER,
        status TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE game_players (
        id TEXT PRIMARY KEY,
        game_id TEXT NOT NULL,
        player_id TEXT NOT NULL,
        player_name TEXT NOT NULL,
        position INTEGER NOT NULL,
        starting_wind TEXT NOT NULL,
        FOREIGN KEY (game_id) REFERENCES games(id),
        FOREIGN KEY (player_id) REFERENCES players(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE turns (
        id TEXT PRIMARY KEY,
        game_id TEXT NOT NULL,
        turn_number INTEGER NOT NULL,
        dominant_wind TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (game_id) REFERENCES games(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE player_turns (
        id TEXT PRIMARY KEY,
        turn_id TEXT NOT NULL,
        game_player_id TEXT NOT NULL,
        player_id TEXT NOT NULL,
        current_wind TEXT NOT NULL,
        hand_score INTEGER NOT NULL,
        net_gain INTEGER NOT NULL,
        is_mahjong INTEGER NOT NULL DEFAULT 0,
        grand_jeu_name TEXT,
        special_flags TEXT,
        tile_data TEXT,
        FOREIGN KEY (turn_id) REFERENCES turns(id),
        FOREIGN KEY (game_player_id) REFERENCES game_players(id)
      )
    ''');
  }

  // ---------------------------------------------------------------------------
  // Players
  // ---------------------------------------------------------------------------

  Future<void> upsertPlayer(Player player) async {
    await db.insert(
      'players',
      {
        'id': player.id,
        'name': player.name,
        'created_at': player.createdAt.millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Player>> getAllPlayers() async {
    final rows = await db.query('players', orderBy: 'name ASC');
    return rows.map(_rowToPlayer).toList();
  }

  Future<Player?> getPlayerById(String id) async {
    final rows = await db.query('players', where: 'id = ?', whereArgs: [id]);
    return rows.isEmpty ? null : _rowToPlayer(rows.first);
  }

  Player _rowToPlayer(Map<String, dynamic> row) => Player(
        id: row['id'] as String,
        name: row['name'] as String,
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(row['created_at'] as int),
      );

  // ---------------------------------------------------------------------------
  // Games
  // ---------------------------------------------------------------------------

  Future<void> insertGame(Game game) async {
    await db.insert('games', _gameToRow(game));
  }

  Future<void> updateGame(Game game) async {
    await db.update('games', _gameToRow(game),
        where: 'id = ?', whereArgs: [game.id]);
  }

  Future<Game?> getGameById(String id) async {
    final rows = await db.query('games', where: 'id = ?', whereArgs: [id]);
    return rows.isEmpty ? null : _rowToGame(rows.first);
  }

  Future<Game?> getLatestInProgressGame() async {
    final rows = await db.query('games',
        where: 'status = ?',
        whereArgs: ['inProgress'],
        orderBy: 'started_at DESC',
        limit: 1);
    return rows.isEmpty ? null : _rowToGame(rows.first);
  }

  Future<List<Game>> getAllGames() async {
    final rows = await db.query('games', orderBy: 'started_at DESC');
    return rows.map(_rowToGame).toList();
  }

  Map<String, dynamic> _gameToRow(Game g) => {
        'id': g.id,
        'started_at': g.startedAt.millisecondsSinceEpoch,
        'completed_at': g.completedAt?.millisecondsSinceEpoch,
        'status':
            g.status == GameStatus.inProgress ? 'inProgress' : 'completed',
      };

  Game _rowToGame(Map<String, dynamic> row) => Game(
        id: row['id'] as String,
        startedAt:
            DateTime.fromMillisecondsSinceEpoch(row['started_at'] as int),
        completedAt: row['completed_at'] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(row['completed_at'] as int),
        status: (row['status'] as String) == 'inProgress'
            ? GameStatus.inProgress
            : GameStatus.completed,
      );

  // ---------------------------------------------------------------------------
  // GamePlayers
  // ---------------------------------------------------------------------------

  Future<void> insertGamePlayer(GamePlayer gp) async {
    await db.insert('game_players', {
      'id': gp.id,
      'game_id': gp.gameId,
      'player_id': gp.playerId,
      'player_name': gp.playerName,
      'position': gp.position,
      'starting_wind': gp.startingWind.name,
    });
  }

  Future<List<GamePlayer>> getGamePlayers(String gameId) async {
    final rows = await db.query('game_players',
        where: 'game_id = ?', whereArgs: [gameId], orderBy: 'position ASC');
    return rows.map(_rowToGamePlayer).toList();
  }

  GamePlayer _rowToGamePlayer(Map<String, dynamic> row) => GamePlayer(
        id: row['id'] as String,
        gameId: row['game_id'] as String,
        playerId: row['player_id'] as String,
        playerName: row['player_name'] as String,
        position: row['position'] as int,
        startingWind: Wind.fromString(row['starting_wind'] as String)!,
      );

  // ---------------------------------------------------------------------------
  // Turns
  // ---------------------------------------------------------------------------

  Future<void> insertTurn(Turn turn) async {
    await db.insert('turns', {
      'id': turn.id,
      'game_id': turn.gameId,
      'turn_number': turn.turnNumber,
      'dominant_wind': turn.dominantWind.name,
      'created_at': turn.createdAt.millisecondsSinceEpoch,
    });
  }

  Future<List<Turn>> getTurnsForGame(String gameId) async {
    final rows = await db.query('turns',
        where: 'game_id = ?', whereArgs: [gameId], orderBy: 'turn_number ASC');
    return rows.map(_rowToTurn).toList();
  }

  Turn _rowToTurn(Map<String, dynamic> row) => Turn(
        id: row['id'] as String,
        gameId: row['game_id'] as String,
        turnNumber: row['turn_number'] as int,
        dominantWind: Wind.fromString(row['dominant_wind'] as String)!,
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(row['created_at'] as int),
      );

  // ---------------------------------------------------------------------------
  // PlayerTurns
  // ---------------------------------------------------------------------------

  Future<void> insertPlayerTurn(PlayerTurn pt) async {
    await db.insert('player_turns', {
      'id': pt.id,
      'turn_id': pt.turnId,
      'game_player_id': pt.gamePlayerId,
      'player_id': pt.playerId,
      'current_wind': pt.currentWind.name,
      'hand_score': pt.handScore,
      'net_gain': pt.netGain,
      'is_mahjong': pt.isMahjong ? 1 : 0,
      'grand_jeu_name': pt.grandJeuName,
      'special_flags': jsonEncode(pt.specialFlags),
      'tile_data': pt.tileDataJson,
    });
  }

  Future<List<PlayerTurn>> getPlayerTurnsForTurn(String turnId) async {
    final rows = await db
        .query('player_turns', where: 'turn_id = ?', whereArgs: [turnId]);
    return rows.map(_rowToPlayerTurn).toList();
  }

  Future<List<PlayerTurn>> getPlayerTurnsForGame(String gameId) async {
    final rows = await db.rawQuery('''
      SELECT pt.* FROM player_turns pt
      INNER JOIN turns t ON t.id = pt.turn_id
      WHERE t.game_id = ?
      ORDER BY t.turn_number ASC
    ''', [gameId]);
    return rows.map(_rowToPlayerTurn).toList();
  }

  PlayerTurn _rowToPlayerTurn(Map<String, dynamic> row) {
    List<String> flags = [];
    final flagsJson = row['special_flags'];
    if (flagsJson != null && (flagsJson as String).isNotEmpty) {
      flags = List<String>.from(jsonDecode(flagsJson) as List);
    }
    return PlayerTurn(
      id: row['id'] as String,
      turnId: row['turn_id'] as String,
      gamePlayerId: row['game_player_id'] as String,
      playerId: row['player_id'] as String,
      currentWind: Wind.fromString(row['current_wind'] as String)!,
      handScore: row['hand_score'] as int,
      netGain: row['net_gain'] as int,
      isMahjong: (row['is_mahjong'] as int) == 1,
      grandJeuName: row['grand_jeu_name'] as String?,
      specialFlags: flags,
      tileDataJson: row['tile_data'] as String?,
    );
  }

  // ---------------------------------------------------------------------------
  // Composite loaders
  // ---------------------------------------------------------------------------

  Future<GameWithPlayers?> loadFullGame(String gameId) async {
    final game = await getGameById(gameId);
    if (game == null) return null;

    final players = await getGamePlayers(gameId);
    final turns = await getTurnsForGame(gameId);

    final turnsWithResults = <TurnWithResults>[];
    for (final turn in turns) {
      final playerTurns = await getPlayerTurnsForTurn(turn.id);
      turnsWithResults
          .add(TurnWithResults(turn: turn, playerTurns: playerTurns));
    }

    return GameWithPlayers(
        game: game, players: players, turns: turnsWithResults);
  }

  Future<List<GameWithPlayers>> loadAllGames() async {
    final games = await getAllGames();
    final result = <GameWithPlayers>[];
    for (final game in games) {
      final full = await loadFullGame(game.id);
      if (full != null) result.add(full);
    }
    return result;
  }

  // ---------------------------------------------------------------------------
  // Statistics helpers
  // ---------------------------------------------------------------------------

  /// Returns all PlayerTurns for a given player across all games.
  Future<List<PlayerTurn>> getPlayerTurnsForPlayer(String playerId) async {
    final rows = await db
        .query('player_turns', where: 'player_id = ?', whereArgs: [playerId]);
    return rows.map(_rowToPlayerTurn).toList();
  }
}
