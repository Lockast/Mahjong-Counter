import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/strings.dart';
import '../../../core/models/wind.dart';
import '../../../providers/game_provider.dart';
import '../../../providers/locale_provider.dart';

class GameSetupScreen extends ConsumerStatefulWidget {
  const GameSetupScreen({super.key});

  @override
  ConsumerState<GameSetupScreen> createState() => _GameSetupScreenState();
}

class _GameSetupScreenState extends ConsumerState<GameSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controllers = List.generate(4, (_) => TextEditingController());

  static const _winds = [Wind.est, Wind.sud, Wind.ouest, Wind.nord];

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _startGame() async {
    if (!_formKey.currentState!.validate()) return;
    final names = _controllers.map((c) => c.text.trim()).toList();

    await ref.read(gameProvider.notifier).startNewGame(playerNames: names);

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(s.newGameTitle)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              s.playerNames,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ...List.generate(4, (i) {
              final wind = _winds[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TextFormField(
                  controller: _controllers[i],
                  decoration: InputDecoration(
                    labelText: s.playerN(i + 1),
                    prefixIcon: _WindIcon(wind: wind, s: s),
                    border: const OutlineInputBorder(),
                    hintText: s.playerWindHint(s.windLabel(wind)),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return s.pleaseEnterName;
                    }
                    return null;
                  },
                ),
              );
            }),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _startGame,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child:
                    Text(s.startButton, style: const TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WindIcon extends StatelessWidget {
  const _WindIcon({required this.wind, required this.s});
  final Wind wind;
  final AppStrings s;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            wind.symbol,
            style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          Text(
            s.windLabel(wind),
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}
