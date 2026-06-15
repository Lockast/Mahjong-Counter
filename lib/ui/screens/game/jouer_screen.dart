import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/strings.dart';
import '../../../providers/game_provider.dart';
import '../../../providers/locale_provider.dart';
import 'game_score_screen.dart';
import 'game_setup_screen.dart';

class JouerScreen extends ConsumerWidget {
  const JouerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final s = ref.watch(stringsProvider);

    return gameState.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('${s.errorPrefix}$e')),
      ),
      data: (game) {
        if (game != null) {
          return const GameScoreScreen();
        }
        return _NoGameScreen(s: s);
      },
    );
  }
}

class _NoGameScreen extends StatelessWidget {
  const _NoGameScreen({required this.s});
  final AppStrings s;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(s.mahjongTitle)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.casino_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              s.noGameInProgress,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              s.startNewGameHint,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              icon: const Icon(Icons.add),
              label: Text(s.newGame),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const GameSetupScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
