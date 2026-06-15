import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/strings.dart';
import '../../../core/models/game_entities.dart';
import '../../../providers/history_provider.dart';
import '../../../providers/locale_provider.dart';
import 'game_detail_screen.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyProvider);
    final s = ref.watch(stringsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(s.historyTitle)),
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('${s.errorPrefix}$e')),
        data: (games) {
          if (games.isEmpty) {
            return Center(child: Text(s.noGamesRecorded));
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(historyProvider.future),
            child: ListView.separated(
              itemCount: games.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (ctx, i) => _GameTile(game: games[i], s: s),
            ),
          );
        },
      ),
    );
  }
}

class _GameTile extends StatelessWidget {
  const _GameTile({required this.game, required this.s});
  final GameWithPlayers game;
  final AppStrings s;

  @override
  Widget build(BuildContext context) {
    final totals = game.totals;
    final sorted = game.players.toList()
      ..sort((a, b) => (totals[b.id] ?? 0).compareTo(totals[a.id] ?? 0));

    final winner = sorted.isNotEmpty ? sorted.first : null;
    final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(game.game.startedAt);
    final isInProgress = game.game.status == GameStatus.inProgress;

    return ListTile(
      leading: Icon(
        isInProgress ? Icons.play_circle_outline : Icons.check_circle_outline,
        color:
            isInProgress ? Theme.of(context).colorScheme.primary : Colors.green,
      ),
      title: Text(dateStr),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(game.players.map((p) => p.playerName).join(' · ')),
          if (winner != null)
            Text(
              isInProgress
                  ? '${s.inProgress} · ${s.turnsCount(game.turns.length)}'
                  : '🏆 ${winner.playerName} (${totals[winner.id] ?? 0} pts) · ${game.turns.length} ${s.tours}',
              style: TextStyle(
                color: isInProgress ? Colors.orange : Colors.green.shade700,
              ),
            ),
        ],
      ),
      isThreeLine: true,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => GameDetailScreen(game: game)),
      ),
    );
  }
}
