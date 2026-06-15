import '../models/tile.dart';
import '../models/combination.dart';

/// Detects Mahjong combinations from a flat list of TileInstances.
///
/// Strategy:
/// - Bonus tiles (fleurs/saisons) are extracted and returned separately.
/// - Exposed tiles and hidden tiles are grouped independently.
/// - For Mahjong hands: uses recursive backtracking to find every valid
///   decomposition into (4 sets + 1 pair); returns all of them.
/// - For non-Mahjong hands: greedy detection (carrés → brelans → suites → paires).
class CombinationDetector {
  CombinationDetector._();

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  static DetectionResult detectMahjong(List<TileInstance> instances) {
    final bonus = instances.where((i) => i.tile.family.isBonus).toList();
    final hand = instances.where((i) => !i.tile.family.isBonus).toList();

    // Separate exposed / hidden groups
    final exposedTiles =
        hand.where((i) => i.exposed).map((i) => i.tile).toList();
    final hiddenTiles =
        hand.where((i) => !i.exposed).map((i) => i.tile).toList();

    // Exposed combinations must already be complete groups (no pair among them
    // in a standard game).  We detect them separately.
    final exposedCombs = _greedySets(exposedTiles, exposed: true);

    // Remaining exposed tiles that didn't fit complete exposed sets
    final usedExposed = exposedCombs.expand((c) => c.tiles).toList();
    final leftoverExposed = List<Tile>.from(exposedTiles);
    for (final t in usedExposed) {
      leftoverExposed.remove(t);
    }

    // Hidden tiles + leftover exposed tiles form the "concealed hand"
    final concealedPool = [...hiddenTiles, ...leftoverExposed];

    // Count how many groups we already have from exposed sets
    final setsNeeded = 4 - exposedCombs.length;

    // We need (setsNeeded) sets + 1 pair from concealedPool
    final decomps = _findDecompositions(
      _sortTiles(concealedPool),
      setsNeeded: setsNeeded,
      needPair: true,
    );

    if (decomps.isEmpty) {
      // No valid complete Mahjong decomposition found – return greedy fallback
      return DetectionResult(
        combinations: [
          ...exposedCombs,
          ..._greedySets(concealedPool, exposed: false),
        ],
        bonusTiles: bonus,
        isValidMahjong: false,
      );
    }

    // Pick the first (or only) decomposition – scoring will be evaluated by the
    // HandScorer which also considers all decompositions.
    final best = decomps.first;
    final hiddenCombs = best
        .map((key) => _keyToCombination(key, concealedPool, exposed: false))
        .toList();

    return DetectionResult(
      combinations: [...exposedCombs, ...hiddenCombs],
      bonusTiles: bonus,
      isValidMahjong: true,
      allDecompositions: decomps.map((d) {
        return [
          ...exposedCombs,
          ...d.map((k) => _keyToCombination(k, concealedPool, exposed: false)),
        ];
      }).toList(),
    );
  }

  static DetectionResult detectRegular(List<TileInstance> instances) {
    final bonus = instances.where((i) => i.tile.family.isBonus).toList();
    final hand = instances.where((i) => !i.tile.family.isBonus).toList();

    final exposedTiles =
        hand.where((i) => i.exposed).map((i) => i.tile).toList();
    final hiddenTiles =
        hand.where((i) => !i.exposed).map((i) => i.tile).toList();

    return DetectionResult(
      combinations: [
        ..._greedySets(exposedTiles, exposed: true),
        ..._greedySets(hiddenTiles, exposed: false),
      ],
      bonusTiles: bonus,
      isValidMahjong: false,
    );
  }

  // ---------------------------------------------------------------------------
  // Recursive decomposition into (setsNeeded sets + optionally 1 pair)
  // ---------------------------------------------------------------------------

  static List<List<_CombKey>> _findDecompositions(
    List<Tile> tiles, {
    required int setsNeeded,
    required bool needPair,
  }) {
    if (setsNeeded == 0 && !needPair) {
      return tiles.isEmpty ? [[]] : [];
    }
    if (tiles.isEmpty) return [];

    final results = <List<_CombKey>>[];
    final first = tiles.first;
    final count = tiles.where((t) => t == first).length;

    // Try carré
    if (setsNeeded > 0 && count >= 4) {
      final rem = _removeN(tiles, first, 4);
      for (final sub in _findDecompositions(rem,
          setsNeeded: setsNeeded - 1, needPair: needPair)) {
        results.add([
          _CombKey(CombType.Kong, [first, first, first, first]),
          ...sub
        ]);
      }
    }

    // Try Pung
    if (setsNeeded > 0 && count >= 3) {
      final rem = _removeN(tiles, first, 3);
      for (final sub in _findDecompositions(rem,
          setsNeeded: setsNeeded - 1, needPair: needPair)) {
        results.add([
          _CombKey(CombType.Pung, [first, first, first]),
          ...sub
        ]);
      }
    }

    // Try Chow (only numbered tiles, only if we can form n, n+1, n+2)
    if (setsNeeded > 0 &&
        first.family.isNumbered &&
        first.number != null &&
        first.number! <= 7) {
      final n = first.number!;
      final t2 = _findTile(tiles, first.family, n + 1);
      final t3 = _findTile(tiles, first.family, n + 2);
      if (t2 != null && t3 != null) {
        var rem = _removeOne(tiles, first);
        rem = _removeOne(rem, t2);
        rem = _removeOne(rem, t3);
        for (final sub in _findDecompositions(rem,
            setsNeeded: setsNeeded - 1, needPair: needPair)) {
          results.add([
            _CombKey(CombType.Chow, [first, t2, t3]),
            ...sub
          ]);
        }
      }
    }

    // Try pair (only if we still need one)
    if (needPair && count >= 2) {
      final rem = _removeN(tiles, first, 2);
      for (final sub in _findDecompositions(rem,
          setsNeeded: setsNeeded, needPair: false)) {
        results.add([
          _CombKey(CombType.Paire, [first, first]),
          ...sub
        ]);
      }
    }

    // Skip first tile entirely (it can't participate in any combination from here)
    // — only if no combination started with it; otherwise we risk infinite loops.
    // We avoid this by construction: we always try to use the first tile.

    return results;
  }

  // ---------------------------------------------------------------------------
  // Greedy set detection (for exposed groups or non-Mahjong hands)
  // ---------------------------------------------------------------------------

  static List<Combination> _greedySets(List<Tile> tiles,
      {required bool exposed}) {
    final result = <Combination>[];
    var remaining = List<Tile>.from(tiles);

    // Carrés
    for (final group in _groupTiles(remaining)) {
      if (group.value.length >= 4) {
        result.add(Combination(
          type: CombType.Kong,
          tiles: [group.key, group.key, group.key, group.key],
          exposed: exposed,
        ));
        remaining = _removeN(remaining, group.key, 4);
      }
    }

    // Brelans
    for (final group in _groupTiles(remaining)) {
      if (group.value.length >= 3) {
        result.add(Combination(
          type: CombType.Pung,
          tiles: [group.key, group.key, group.key],
          exposed: exposed,
        ));
        remaining = _removeN(remaining, group.key, 3);
      }
    }

    // Suites (numbered tiles only)
    bool found = true;
    while (found) {
      found = false;
      final sorted = _sortTiles(remaining);
      for (final t in sorted) {
        if (!t.family.isNumbered || t.number == null || t.number! > 7) continue;
        final t2 = _findTile(remaining, t.family, t.number! + 1);
        final t3 = _findTile(remaining, t.family, t.number! + 2);
        if (t2 != null && t3 != null) {
          result.add(Combination(
              type: CombType.Chow, tiles: [t, t2, t3], exposed: exposed));
          remaining = _removeOne(remaining, t);
          remaining = _removeOne(remaining, t2);
          remaining = _removeOne(remaining, t3);
          found = true;
          break;
        }
      }
    }

    // Pairs
    for (final group in _groupTiles(remaining)) {
      if (group.value.length >= 2) {
        result.add(Combination(
          type: CombType.Paire,
          tiles: [group.key, group.key],
          exposed: exposed,
        ));
        remaining = _removeN(remaining, group.key, 2);
      }
    }

    return result;
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  static List<Tile> _sortTiles(List<Tile> tiles) {
    final sorted = List<Tile>.from(tiles);
    sorted.sort((a, b) {
      final famCmp = a.family.index.compareTo(b.family.index);
      if (famCmp != 0) return famCmp;
      return (a.number ?? 0).compareTo(b.number ?? 0);
    });
    return sorted;
  }

  static List<MapEntry<Tile, List<Tile>>> _groupTiles(List<Tile> tiles) {
    final map = <String, List<Tile>>{};
    for (final t in tiles) {
      map.putIfAbsent(t.id, () => []).add(t);
    }
    return map.entries.map((e) => MapEntry(e.value.first, e.value)).toList();
  }

  static Tile? _findTile(List<Tile> tiles, TileFamily family, int number) {
    for (final t in tiles) {
      if (t.family == family && t.number == number) return t;
    }
    return null;
  }

  static List<Tile> _removeOne(List<Tile> tiles, Tile target) {
    final result = List<Tile>.from(tiles);
    result.remove(target);
    return result;
  }

  static List<Tile> _removeN(List<Tile> tiles, Tile target, int n) {
    var result = List<Tile>.from(tiles);
    for (var i = 0; i < n; i++) {
      result.remove(target);
    }
    return result;
  }

  static Combination _keyToCombination(_CombKey key, List<Tile> pool,
      {required bool exposed}) {
    return Combination(type: key.type, tiles: key.tiles, exposed: exposed);
  }
}

// ---------------------------------------------------------------------------
// Internal key type for decomposition results
// ---------------------------------------------------------------------------

class _CombKey {
  final CombType type;
  final List<Tile> tiles;
  const _CombKey(this.type, this.tiles);
}

// ---------------------------------------------------------------------------
// Result object
// ---------------------------------------------------------------------------

class DetectionResult {
  final List<Combination> combinations;
  final List<TileInstance> bonusTiles;
  final bool isValidMahjong;
  final List<List<Combination>>? allDecompositions;

  const DetectionResult({
    required this.combinations,
    required this.bonusTiles,
    this.isValidMahjong = false,
    this.allDecompositions,
  });
}
