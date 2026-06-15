import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/game_entities.dart';
import '../../../core/models/wind.dart';
import '../../../providers/game_provider.dart';
import '../../../providers/locale_provider.dart';
import 'hand_input_screen.dart';

class TurnInputScreen extends ConsumerStatefulWidget {
  const TurnInputScreen({super.key});

  @override
  ConsumerState<TurnInputScreen> createState() => _TurnInputScreenState();
}

class _TurnInputScreenState extends ConsumerState<TurnInputScreen> {
  Wind _dominantWind = Wind.est;
  final Map<String, TurnPlayerInput?> _playerInputs = {};
  bool _validating = false;

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final game = gameState.valueOrNull;
    if (game == null) return const SizedBox.shrink();
    final s = ref.watch(stringsProvider);

    final turnIndex = game.turns.length;
    final mahjongCount =
        _playerInputs.values.where((pi) => pi?.isMahjong == true).length;
    final allEntered = game.players.every((gp) => _playerInputs[gp.id] != null);

    return Scaffold(
      appBar: AppBar(
        title: Text(s.turnN(turnIndex + 1)),
        leading: const BackButton(),
      ),
      body: Column(
        children: [
          // ---- Dominant wind selector ----
          SizedBox(
            height: 52,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(s.windColon,
                      style: Theme.of(context).textTheme.labelLarge),
                ),
                Expanded(
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: Wind.values.map((w) {
                      final selected = _dominantWind == w;
                      final cs = Theme.of(context).colorScheme;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text('${w.symbol} ${s.windLabel(w)}',
                              style: TextStyle(
                                fontWeight: selected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: selected
                                    ? cs.onPrimaryContainer
                                    : cs.onSurface,
                              )),
                          selected: selected,
                          selectedColor: cs.primaryContainer,
                          onSelected: (_) => setState(() => _dominantWind = w),
                          visualDensity: VisualDensity.compact,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // ---- Player list ----
          Expanded(
            child: ListView.separated(
              itemCount: game.players.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (ctx, i) {
                final gp = game.players[i];
                final currentWind = gp.windAtTurn(turnIndex);
                final input = _playerInputs[gp.id];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _playerColorOf(i),
                    child: Text(
                      currentWind.symbol,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(gp.playerName),
                  subtitle: Text(
                    '${currentWind.symbol} ${s.windLabel(currentWind)}',
                  ),
                  trailing: input == null
                      ? Text(s.toEnter,
                          style: const TextStyle(color: Colors.grey))
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (input.isMahjong)
                              const Icon(Icons.star,
                                  color: Colors.amber, size: 18),
                            if (input.grandJeuName != null)
                              const Icon(Icons.military_tech,
                                  color: Colors.deepOrange, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              '${input.handScore} pts',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                  onTap: () => _openHandInput(context, game, gp, currentWind),
                );
              },
            ),
          ),
          // ---- Conflict / help message ----
          if (mahjongCount > 1)
            _Banner(
              message: s.onlyOneMahjong,
              color: Colors.red.shade100,
            ),
          if (allEntered && mahjongCount == 0)
            _Banner(
              message: s.pleasePickMahjong,
              color: Colors.orange.shade100,
            ),
          // ---- Validate button ----
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: allEntered && mahjongCount == 1 && !_validating
                    ? _validateTurn
                    : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: _validating
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(s.validateTurn,
                          style: const TextStyle(fontSize: 16)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openHandInput(
    BuildContext context,
    GameWithPlayers game,
    GamePlayer gp,
    Wind currentWind,
  ) async {
    final result = await Navigator.of(context).push<TurnPlayerInput>(
      MaterialPageRoute(
        builder: (_) => HandInputScreen(
          gamePlayer: gp,
          currentWind: currentWind,
          dominantWind: _dominantWind,
          existingInput: _playerInputs[gp.id],
        ),
      ),
    );
    if (result != null) {
      setState(() => _playerInputs[gp.id] = result);
    }
  }

  Future<void> _validateTurn() async {
    setState(() => _validating = true);
    try {
      final game = ref.read(gameProvider).valueOrNull!;
      final inputs = game.players.map((gp) => _playerInputs[gp.id]!).toList();
      await ref.read(gameProvider.notifier).addTurn(
            dominantWind: _dominantWind,
            playerInputs: inputs,
          );
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _validating = false);
    }
  }

  Color _playerColorOf(int index) {
    const colors = [
      Color(0xFF1565C0),
      Color(0xFF2E7D32),
      Color(0xFFE65100),
      Color(0xFF6A1B9A),
    ];
    return colors[index % colors.length];
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.message, required this.color});
  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: color,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Text(message, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}
