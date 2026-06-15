import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/strings.dart';
import '../../../core/models/game_entities.dart';
import '../../../providers/game_provider.dart';
import '../../../providers/locale_provider.dart';
import 'turn_input_screen.dart';

// 4 distinct colors for the 4 player columns
const _playerColors = [
  Color(0xFF1565C0), // blue  — Est
  Color(0xFF2E7D32), // green — Sud
  Color(0xFFE65100), // orange — Ouest
  Color(0xFF6A1B9A), // purple — Nord
];

class GameScoreScreen extends ConsumerWidget {
  const GameScoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider).valueOrNull;
    if (game == null) return const SizedBox.shrink();
    final s = ref.watch(stringsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat('dd/MM/yyyy').format(game.game.startedAt)),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) async {
              if (v == 'end') {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text(s.endGameConfirmTitle),
                    content: Text(s.endGameConfirmBody),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(s.cancel)),
                      FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(s.end)),
                    ],
                  ),
                );
                if (confirm == true) {
                  await ref.read(gameProvider.notifier).endGame();
                }
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: 'end', child: Text(s.endGame)),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // ---- Player headers ----
          _PlayerHeaderRow(game: game, s: s),
          // ---- Turn rows ----
          Expanded(
            child: game.turns.isEmpty
                ? Center(
                    child: Text(s.noTurnsPlayed, textAlign: TextAlign.center))
                : ListView.builder(
                    itemCount: game.turns.length,
                    itemBuilder: (ctx, i) =>
                        _TurnRow(game: game, turnIndex: i, s: s),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openTurnInput(context),
        tooltip: s.newTurnTooltip,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _openTurnInput(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const TurnInputScreen()),
    );
  }
}

// ---------------------------------------------------------------------------
// Player header row
// ---------------------------------------------------------------------------

class _PlayerHeaderRow extends StatelessWidget {
  const _PlayerHeaderRow({required this.game, required this.s});
  final GameWithPlayers game;
  final AppStrings s;

  @override
  Widget build(BuildContext context) {
    final totals = game.totals;
    return Material(
      elevation: 2,
      child: Row(
        children: game.players.asMap().entries.map((e) {
          final idx = e.key;
          final gp = e.value;
          final color = _playerColors[idx];
          final total = totals[gp.id] ?? 0;
          final currentWind = gp.windAtTurn(game.turns.length);
          return Expanded(
            child: Container(
              color: color,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              child: Column(
                children: [
                  Text(
                    gp.playerName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${currentWind.symbol} ${s.windLabel(currentWind)}',
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$total',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// One turn row
// ---------------------------------------------------------------------------

class _TurnRow extends StatelessWidget {
  const _TurnRow(
      {required this.game, required this.turnIndex, required this.s});
  final GameWithPlayers game;
  final int turnIndex;
  final AppStrings s;

  @override
  Widget build(BuildContext context) {
    final turn = game.turns[turnIndex];
    final mahjongResult = turn.mahjongResult();
    final wind = turn.turn.dominantWind;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Turn header
        Container(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          child: Row(
            children: [
              Text(
                s.turnWind(
                    turn.turn.turnNumber, wind.symbol, s.windLabel(wind)),
                style: Theme.of(context).textTheme.labelSmall,
              ),
              if (mahjongResult != null) ...[
                const SizedBox(width: 8),
                Text(
                  '🀄 ${_playerNameOf(mahjongResult.gamePlayerId)}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ],
          ),
        ),
        // Gains row
        Row(
          children: game.players.asMap().entries.map((e) {
            final gp = e.value;
            final pt = turn.playerTurns
                .where((p) => p.gamePlayerId == gp.id)
                .firstOrNull;
            final gain = pt?.netGain ?? 0;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  children: [
                    Text(
                      gain >= 0 ? '+$gain' : '$gain',
                      style: TextStyle(
                        color: gain > 0
                            ? Colors.green.shade700
                            : gain < 0
                                ? Colors.red.shade700
                                : Colors.grey,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (pt != null && pt.grandJeuName != null)
                      Text(
                        'GJ',
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.amber.shade700,
                        ),
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const Divider(height: 1),
      ],
    );
  }

  String _playerNameOf(String gamePlayerId) {
    return game.players
        .firstWhere((p) => p.id == gamePlayerId,
            orElse: () => game.players.first)
        .playerName;
  }
}
