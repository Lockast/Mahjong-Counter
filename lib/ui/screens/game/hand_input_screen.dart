import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/strings.dart';
import '../../../core/models/game_entities.dart';
import '../../../core/models/tile.dart';
import '../../../core/models/wind.dart';
import '../../../core/scoring/grand_jeux.dart';
import '../../../core/scoring/hand_scorer.dart';
import '../../../providers/game_provider.dart';
import '../../../providers/locale_provider.dart';
import '../../widgets/tile_image.dart';

// Height of the fixed selected-tile strip
const _kTileStripHeight = 76.0;
// Max tiles to show before horizontal scroll
const _kMaxHandSize = 14;

class HandInputScreen extends ConsumerStatefulWidget {
  const HandInputScreen({
    super.key,
    required this.gamePlayer,
    required this.currentWind,
    required this.dominantWind,
    this.existingInput,
  });

  final GamePlayer gamePlayer;
  final Wind currentWind;
  final Wind dominantWind;
  final TurnPlayerInput? existingInput;

  @override
  ConsumerState<HandInputScreen> createState() => _HandInputScreenState();
}

class _HandInputScreenState extends ConsumerState<HandInputScreen> {
  bool _isMahjong = false;
  String? _grandJeuName;

  // Mahjong special flags
  bool _tuileExposee = false;
  bool _tuileDuMur = false;
  bool _pecheLune = false;
  bool _volKong = false;
  bool _surPremiereDonne = false;

  // Main appelante is available for ALL players
  bool _mainAppelante = false;

  // Tile selection state
  final List<TileInstance> _selectedTiles = [];
  bool _exposedMode = false;

  HandResult? _result;

  @override
  void initState() {
    super.initState();
    final ex = widget.existingInput;
    if (ex != null) {
      _isMahjong = ex.isMahjong;
      _grandJeuName = ex.grandJeuName;
      _selectedTiles.addAll(ex.tiles);
      final flags = ex.handInput?.specialFlags ?? <String>[];
      _tuileExposee = flags.contains('tuileExposee');
      _tuileDuMur = flags.contains('tuileDuMur');
      _pecheLune = flags.contains('pecheLune');
      _volKong = flags.contains('volKongExpose');
      _mainAppelante = flags.contains('mainAppelante');
      _surPremiereDonne = flags.contains('surPremiereDonne');
      if (ex.handScore > 0) _calculateScore();
    }
  }

  HandInput get _handInput => HandInput(
        tiles: _selectedTiles,
        isMahjong: _isMahjong,
        grandJeuName: _grandJeuName,
        tuileExposee: _tuileExposee,
        tuileDuMur: _tuileDuMur,
        pecheLune: _pecheLune,
        volKongExpose: _volKong,
        mainAppelante: _mainAppelante,
        surPremiereDonne: _surPremiereDonne,
        playerWind: widget.currentWind,
        dominantWind: widget.dominantWind,
        locale: ref.read(localeProvider) ?? AppLocale.fr,
      );

  void _calculateScore() {
    setState(() => _result = HandScorer.score(_handInput));
  }

  void _addTile(Tile tile) {
    setState(() {
      _selectedTiles.add(TileInstance(tile: tile, exposed: _exposedMode));
      _result = null;
    });
  }

  void _removeLast() {
    if (_selectedTiles.isNotEmpty) {
      setState(() {
        _selectedTiles.removeLast();
        _result = null;
      });
    }
  }

  void _clearTiles() {
    setState(() {
      _selectedTiles.clear();
      _result = null;
    });
  }

  void _confirm() {
    if (_result == null) _calculateScore();
    final r = _result!;
    Navigator.of(context).pop(TurnPlayerInput(
      gamePlayerId: widget.gamePlayer.id,
      handScore: r.score,
      isMahjong: _isMahjong,
      grandJeuName: _grandJeuName,
      handInput: _handInput,
      tiles: List.from(_selectedTiles),
    ));
  }

  void _setTuileExposee(bool v) => setState(() {
        _tuileExposee = v;
        if (v) {
          _tuileDuMur = false;
          _pecheLune = false;
          _surPremiereDonne = false;
        }
        _result = null;
      });

  void _setTuileDuMur(bool v) => setState(() {
        _tuileDuMur = v;
        if (v) {
          _tuileExposee = false;
          _volKong = false;
          _surPremiereDonne = false;
        }
        _result = null;
      });

  void _setPecheLune(bool v) => setState(() {
        _pecheLune = v;
        if (v) {
          _tuileExposee = false;
          _volKong = false;
          _surPremiereDonne = false;
        }
        _result = null;
      });

  void _setVolKong(bool v) => setState(() {
        _volKong = v;
        if (v) {
          _tuileDuMur = false;
          _pecheLune = false;
          _surPremiereDonne = false;
        }
        _result = null;
      });

  void _setSurPremiereDonne(bool v) => setState(() {
        _surPremiereDonne = v;
        if (v) {
          _tuileExposee = false;
          _tuileDuMur = false;
          _pecheLune = false;
          _volKong = false;
          _mainAppelante = false;
        }
        _result = null;
      });

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.gamePlayer.playerName),
            Text(
              '${widget.currentWind.symbol} ${s.windLabel(widget.currentWind)}',
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
        actions: [
          if (_result != null)
            TextButton(
              onPressed: _confirm,
              child: Text(s.ok),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // ---- Main appelante for ALL players ----
          CheckboxListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text(s.callingHand),
            subtitle: _isMahjong
                ? Text(s.winnerScoreDouble)
                : Text(s.loserFlowersOnly),
            value: _mainAppelante,
            onChanged: _surPremiereDonne
                ? null
                : (v) => setState(() {
                      _mainAppelante = v ?? false;
                      _result = null;
                    }),
          ),
          const Divider(height: 1),

          // ---- Mah-Jong / Grand Jeu toggles ----
          const SizedBox(height: 8),
          _SectionHeader(s.handType),
          Row(
            children: [
              Expanded(
                child: _ToggleCard(
                  label: s.mahjongTitle,
                  icon: Icons.star,
                  active: _isMahjong && _grandJeuName == null,
                  onTap: () => setState(() {
                    _isMahjong = !_isMahjong;
                    if (_isMahjong) _grandJeuName = null;
                    _result = null;
                  }),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ToggleCard(
                  label: _grandJeuName == null
                      ? s.grandJeuLabel
                      : GrandJeux.displayName(_grandJeuName!, isEn: s.isEn),
                  icon: Icons.military_tech,
                  active: _grandJeuName != null,
                  onTap: () => _showGrandJeuSelector(s),
                ),
              ),
            ],
          ),

          // ---- Mahjong special flags ----
          if (_isMahjong && _grandJeuName == null) ...[
            const SizedBox(height: 8),
            _SectionHeader(s.mahjongBonuses),
            Text(
              s.incompatibleOptions,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _FlagChip(
                  label: s.exposedTile,
                  active: _tuileExposee,
                  disabled: _tuileDuMur || _pecheLune || _surPremiereDonne,
                  onChanged: _setTuileExposee,
                ),
                _FlagChip(
                  label: s.wallTile,
                  active: _tuileDuMur,
                  disabled: _tuileExposee || _volKong || _surPremiereDonne,
                  onChanged: _setTuileDuMur,
                ),
                _FlagChip(
                  label: s.moonFromDeep,
                  active: _pecheLune,
                  disabled: _tuileExposee || _volKong || _surPremiereDonne,
                  onChanged: _setPecheLune,
                ),
                _FlagChip(
                  label: s.stealKong,
                  active: _volKong,
                  disabled: _tuileDuMur || _pecheLune || _surPremiereDonne,
                  onChanged: _setVolKong,
                ),
                _FlagChip(
                  label: s.firstDeal,
                  active: _surPremiereDonne,
                  disabled:
                      _tuileExposee || _tuileDuMur || _pecheLune || _volKong,
                  onChanged: _setSurPremiereDonne,
                ),
              ],
            ),
          ],

          // ---- Grand Jeu: no tile input needed ----
          if (_grandJeuName != null) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      GrandJeux.displayName(_grandJeuName!, isEn: s.isEn),
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${GrandJeux.scoreFor(_grandJeuName!) ?? 0} ${s.points}',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(
                              color: Theme.of(context).colorScheme.primary),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () {
                        final score = GrandJeux.scoreFor(_grandJeuName!) ?? 0;
                        Navigator.of(context).pop(TurnPlayerInput(
                          gamePlayerId: widget.gamePlayer.id,
                          handScore: score,
                          isMahjong: true,
                          grandJeuName: _grandJeuName,
                          tiles: const [],
                        ));
                      },
                      child: Text(s.confirmButton),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // ---- Tile selector ----
          if (_grandJeuName == null) ...[
            const SizedBox(height: 12),
            _SectionHeader(s.tilesCount(_selectedTiles.length, _kMaxHandSize)),

            // Fixed-height tile strip
            _TileStrip(
              tiles: _selectedTiles,
              onRemoveLast: _removeLast,
              onClear: _clearTiles,
              hintText: s.tapTilesToSelect,
              undoTooltip: s.undoLast,
              clearTooltip: s.clearAll,
            ),
            const SizedBox(height: 8),

            // Exposé / Caché toggle
            Row(
              children: [
                Text(s.modeLabel),
                ChoiceChip(
                  label: Text(s.hidden),
                  selected: !_exposedMode,
                  onSelected: (_) => setState(() => _exposedMode = false),
                  visualDensity: VisualDensity.compact,
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: Text(s.exposed),
                  selected: _exposedMode,
                  onSelected: (_) => setState(() => _exposedMode = true),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Tile grid
            _TileGrid(onTileTap: _addTile, s: s),
          ],

          // ---- Score result ----
          if (_result != null) ...[
            const SizedBox(height: 16),
            _ScoreCard(result: _result!, s: s),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _confirm,
              child: Text(s.confirmScore(_result!.score)),
            ),
          ] else if (_grandJeuName == null) ...[
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _calculateScore,
              child: Text(s.calculateScore),
            ),
          ],
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  void _showGrandJeuSelector(AppStrings s) {
    showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        builder: (_, controller) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(s.chooseGrandJeu,
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            Expanded(
              child: ListView.separated(
                controller: controller,
                itemCount: GrandJeux.all.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final gj = GrandJeux.all[i];
                  return ListTile(
                    title: Text(s.isEn ? gj.nameEn : gj.name),
                    trailing: Text('${gj.points} pts',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    onTap: () => Navigator.pop(context, gj.name),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ).then((name) {
      if (name != null) {
        setState(() {
          _grandJeuName = name;
          _isMahjong = true;
          _result = null;
        });
      }
    });
  }
}

// ---------------------------------------------------------------------------
// Fixed-height selected-tile strip with placeholder slots
// ---------------------------------------------------------------------------

class _TileStrip extends StatelessWidget {
  const _TileStrip({
    required this.tiles,
    required this.onRemoveLast,
    required this.onClear,
    required this.hintText,
    required this.undoTooltip,
    required this.clearTooltip,
  });

  final List<TileInstance> tiles;
  final VoidCallback onRemoveLast;
  final VoidCallback onClear;
  final String hintText;
  final String undoTooltip;
  final String clearTooltip;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: _kTileStripHeight,
      decoration: BoxDecoration(
        border: Border.all(color: cs.outlineVariant),
        borderRadius: BorderRadius.circular(8),
        color: cs.surfaceContainerHighest.withAlpha(80),
      ),
      child: Row(
        children: [
          Expanded(
            child: tiles.isEmpty
                ? Center(
                    child: Text(
                      hintText,
                      style: TextStyle(
                          color: cs.onSurface.withAlpha(100), fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                    itemCount: tiles.length,
                    itemBuilder: (_, i) {
                      final ti = tiles[i];
                      return Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: TileImage(
                          tile: ti.tile,
                          size: 40,
                          selected: true,
                          exposed: ti.exposed,
                        ),
                      );
                    },
                  ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              _StripIconButton(
                icon: Icons.undo,
                tooltip: undoTooltip,
                onPressed: tiles.isNotEmpty ? onRemoveLast : null,
              ),
              const SizedBox(height: 2),
              _StripIconButton(
                icon: Icons.clear_all,
                tooltip: clearTooltip,
                onPressed: tiles.isNotEmpty ? onClear : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Icon button for the tile strip: no ripple/splash overlay, icon turns red
/// while pressed. Uses a fixed [SizedBox] so two instances stacked vertically
/// always fit inside [_kTileStripHeight] without overflowing.
class _StripIconButton extends StatefulWidget {
  const _StripIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  State<_StripIconButton> createState() => _StripIconButtonState();
}

class _StripIconButtonState extends State<_StripIconButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final enabled = widget.onPressed != null;
    final color = !enabled
        ? cs.onSurface.withAlpha(60)
        : _pressed
            ? Colors.red
            : cs.onSurface;

    return Tooltip(
      message: widget.tooltip,
      child: GestureDetector(
        onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
        onTapUp: enabled
            ? (_) {
                setState(() => _pressed = false);
                widget.onPressed!();
              }
            : null,
        onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
        child: SizedBox(
          width: 32,
          height: 32,
          child: Center(child: Icon(widget.icon, size: 20, color: color)),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tile grid
// ---------------------------------------------------------------------------

class _TileGrid extends StatelessWidget {
  const _TileGrid({required this.onTileTap, required this.s});
  final ValueChanged<Tile> onTileTap;
  final AppStrings s;

  @override
  Widget build(BuildContext context) {
    final all = TileCatalog.all;
    final groups = <String, List<Tile>>{};
    for (final t in all) {
      groups.putIfAbsent(t.family.name, () => []).add(t);
    }

    final sections = [
      (s.familyBamboo, groups['bambou'] ?? []),
      (s.familyCharacters, groups['caracteres'] ?? []),
      (s.familyCircles, groups['sapek'] ?? []),
      (s.familyWinds, groups['vent'] ?? []),
      (s.familyDragons, groups['dragon'] ?? []),
      (s.familyFlowers, groups['fleur'] ?? []),
      (s.familySeasons, groups['saison'] ?? []),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sections.map((sec) {
        final (label, tiles) = sec;
        if (tiles.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: tiles
                  .map((t) => TileImage(
                        tile: t,
                        size: 44,
                        onTap: () => onTileTap(t),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 12),
          ],
        );
      }).toList(),
    );
  }
}

// ---------------------------------------------------------------------------
// Score card
// ---------------------------------------------------------------------------

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({required this.result, required this.s});
  final HandResult result;
  final AppStrings s;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(s.scoreLabel,
                    style: Theme.of(context).textTheme.titleMedium),
                Text(
                  '${result.score} ${s.pts}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold),
                ),
                if (result.cappedAt1000)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(s.cappedLabel,
                        style: const TextStyle(
                            color: Colors.orange, fontSize: 12)),
                  ),
              ],
            ),
            const Divider(),
            ...result.explanations.map((e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text('• $e',
                      style: Theme.of(context).textTheme.bodySmall),
                )),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 6),
        child: Text(text,
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(color: Theme.of(context).colorScheme.primary)),
      );
}

class _ToggleCard extends StatelessWidget {
  const _ToggleCard({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      color: active ? cs.primaryContainer : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: active ? cs.onPrimaryContainer : cs.onSurface),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontWeight: active ? FontWeight.bold : FontWeight.normal,
                    color: active ? cs.onPrimaryContainer : cs.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FlagChip extends StatelessWidget {
  const _FlagChip({
    required this.label,
    required this.active,
    required this.onChanged,
    this.disabled = false,
  });
  final String label;
  final bool active;
  final bool disabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: active,
      onSelected: disabled ? null : onChanged,
    );
  }
}
