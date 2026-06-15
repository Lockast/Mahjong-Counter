import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/strings.dart';
import '../../../core/models/game_entities.dart';
import '../../../core/scoring/grand_jeux.dart';
import '../../../providers/game_provider.dart';
import '../../../providers/locale_provider.dart';

const _playerColors = [
  Color(0xFF1565C0),
  Color(0xFF2E7D32),
  Color(0xFFE65100),
  Color(0xFF6A1B9A),
];

class GameDetailScreen extends ConsumerWidget {
  const GameDetailScreen({super.key, required this.game});
  final GameWithPlayers game;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isInProgress = game.game.status == GameStatus.inProgress;
    final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(game.game.startedAt);
    final s = ref.watch(stringsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(dateStr),
        actions: [
          if (isInProgress)
            FilledButton.icon(
              icon: const Icon(Icons.play_arrow),
              label: Text(s.resumeButton),
              onPressed: () async {
                await ref.read(gameProvider.notifier).resumeGame(game.game.id);
                if (context.mounted) Navigator.of(context).pop();
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // ---- Final scores header ----
          _ScoreHeader(game: game),
          const Divider(height: 1),
          // ---- Turn list ----
          Expanded(
            child: ListView.builder(
              itemCount: game.turns.length,
              itemBuilder: (ctx, i) =>
                  _TurnDetail(game: game, turnIndex: i, s: s),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreHeader extends StatelessWidget {
  const _ScoreHeader({required this.game});
  final GameWithPlayers game;

  @override
  Widget build(BuildContext context) {
    final totals = game.totals;
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: game.players.asMap().entries.map((e) {
          final gp = e.value;
          final color = _playerColors[e.key];
          final total = totals[gp.id] ?? 0;
          return Expanded(
            child: Column(
              children: [
                Text(
                  gp.playerName,
                  style: TextStyle(fontWeight: FontWeight.bold, color: color),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '$total',
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold, color: color),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _TurnDetail extends StatelessWidget {
  const _TurnDetail(
      {required this.game, required this.turnIndex, required this.s});
  final GameWithPlayers game;
  final int turnIndex;
  final AppStrings s;

  @override
  Widget build(BuildContext context) {
    final tw = game.turns[turnIndex];
    final mahjong = tw.mahjongResult();
    final runningTotals = game.totalsAtTurn(turnIndex);
    final wind = tw.turn.dominantWind;

    return ExpansionTile(
      leading: CircleAvatar(
        radius: 14,
        child:
            Text('${tw.turn.turnNumber}', style: const TextStyle(fontSize: 12)),
      ),
      title: Row(
        children: [
          Text(s.windHeader(wind.symbol, s.windLabel(wind))),
          if (mahjong != null) ...[
            const SizedBox(width: 8),
            Text(
              '🀄 ${_nameOf(mahjong.gamePlayerId)}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
      subtitle: Row(
        children: game.players.map((gp) {
          final pt =
              tw.playerTurns.where((p) => p.gamePlayerId == gp.id).firstOrNull;
          final gain = pt?.netGain ?? 0;
          return Expanded(
            child: Text(
              gain >= 0 ? '+$gain' : '$gain',
              style: TextStyle(
                color: gain > 0
                    ? Colors.green.shade700
                    : gain < 0
                        ? Colors.red.shade700
                        : Colors.grey,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          );
        }).toList(),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(1),
              2: FlexColumnWidth(1),
              3: FlexColumnWidth(1),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest),
                children: [
                  TableCell(
                      child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Text(s.colPlayer))),
                  ...[s.colHand, s.colGain, s.colTotal].map((h) => TableCell(
                        child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Text(h, textAlign: TextAlign.right)),
                      )),
                ],
              ),
              ...game.players.map((gp) {
                final pt = tw.playerTurns
                    .where((p) => p.gamePlayerId == gp.id)
                    .firstOrNull;
                final gain = pt?.netGain ?? 0;
                final hand = pt?.handScore ?? 0;
                final total = runningTotals[gp.id] ?? 0;
                return TableRow(
                  children: [
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Row(children: [
                          if (pt?.isMahjong == true)
                            const Text('🀄 ', style: TextStyle(fontSize: 12)),
                          if (pt?.grandJeuName != null)
                            const Text('🏆 ', style: TextStyle(fontSize: 12)),
                          Text(gp.playerName, overflow: TextOverflow.ellipsis),
                        ]),
                      ),
                    ),
                    TableCell(
                        child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Text('$hand', textAlign: TextAlign.right))),
                    TableCell(
                        child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Text(gain >= 0 ? '+$gain' : '$gain',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: gain > 0
                                      ? Colors.green.shade700
                                      : Colors.red.shade700,
                                )))),
                    TableCell(
                        child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Text('$total',
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)))),
                  ],
                );
              }),
            ],
          ),
        ),
        if (tw.playerTurns.any((pt) => pt.grandJeuName != null))
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Wrap(
              spacing: 8,
              children: tw.playerTurns
                  .where((pt) => pt.grandJeuName != null)
                  .map((pt) => Chip(
                        label: Text(
                            '${_nameOf(pt.gamePlayerId)} : ${GrandJeux.displayName(pt.grandJeuName!, isEn: s.isEn)}'),
                        avatar: const Icon(Icons.military_tech, size: 16),
                      ))
                  .toList(),
            ),
          ),
      ],
    );
  }

  String _nameOf(String gamePlayerId) => game.players
      .firstWhere((p) => p.id == gamePlayerId, orElse: () => game.players.first)
      .playerName;
}
