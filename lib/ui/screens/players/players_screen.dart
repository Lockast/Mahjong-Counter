import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/strings.dart';
import '../../../core/models/game_entities.dart';
import '../../../core/scoring/grand_jeux.dart';
import '../../../providers/locale_provider.dart';
import '../../../providers/stats_provider.dart';

class PlayersScreen extends ConsumerWidget {
  const PlayersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(allPlayersStatsProvider);
    final s = ref.watch(stringsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(s.playersTitle)),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('${s.errorPrefix}$e')),
        data: (statsList) {
          if (statsList.isEmpty) {
            return Center(child: Text(s.noPlayersRecorded));
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(allPlayersStatsProvider.future),
            child: ListView.separated(
              itemCount: statsList.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (ctx, i) => _PlayerTile(stats: statsList[i], s: s),
            ),
          );
        },
      ),
    );
  }
}

class _PlayerTile extends StatelessWidget {
  const _PlayerTile({required this.stats, required this.s});
  final PlayerStats stats;
  final AppStrings s;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: CircleAvatar(
        child: Text(
          stats.player.name.substring(0, 1).toUpperCase(),
        ),
      ),
      title: Text(stats.player.name,
          style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(s.playerSubtitle(
          stats.gamesPlayed, stats.meanFinalScore.toStringAsFixed(0))),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: _PlayerDetail(stats: stats, s: s),
        ),
      ],
    );
  }
}

class _PlayerDetail extends StatelessWidget {
  const _PlayerDetail({required this.stats, required this.s});
  final PlayerStats stats;
  final AppStrings s;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Rank distribution
        _Subtitle(s.rankings),
        _RankRow(stats: stats, s: s),
        const SizedBox(height: 12),

        // Score stats
        _Subtitle(s.finalScores),
        Row(
          children: [
            _StatBox(s.average, stats.meanFinalScore.toStringAsFixed(0)),
            const SizedBox(width: 16),
            _StatBox(s.median, stats.medianFinalScore.toStringAsFixed(0)),
          ],
        ),
        const SizedBox(height: 12),

        // Grand Jeux
        if (stats.grandJeuxAchieved.isNotEmpty) ...[
          _Subtitle(s.grandJeuxAchieved),
          ...stats.grandJeuxAchieved.entries.map((e) => Text(
              '• ${GrandJeux.displayName(e.key, isEn: s.isEn)} (×${e.value})')),
          const SizedBox(height: 12),
        ],

        // Tile favorites
        if (!stats.hasEnoughTileData)
          Text(
            s.notEnoughData,
            style: TextStyle(color: Colors.grey.shade600),
          ),
      ],
    );
  }
}

class _Subtitle extends StatelessWidget {
  const _Subtitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(color: Theme.of(context).colorScheme.primary)),
      );
}

class _RankRow extends StatelessWidget {
  const _RankRow({required this.stats, required this.s});
  final PlayerStats stats;
  final AppStrings s;

  @override
  Widget build(BuildContext context) {
    if (stats.gamesPlayed == 0) return const Text('—');
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [1, 2, 3, 4].map((rank) {
        final pct = stats.rankPct(rank);
        return Column(
          children: [
            Text('$rank${s.ordinalSuffix(rank)}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('${pct.toStringAsFixed(0)} %'),
          ],
        );
      }).toList(),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(value,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      );
}
