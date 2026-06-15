import 'tile.dart';
import 'wind.dart';

enum CombType { Chow, Paire, Pung, Kong }

class Combination {
  final CombType type;
  final List<Tile> tiles; // 2, 3 or 4 tiles depending on type
  final bool exposed; // true = exposé

  const Combination({
    required this.type,
    required this.tiles,
    required this.exposed,
  });

  Tile get representativeTile => tiles.first;

  // -------------------------------------------------------------------------
  // Base-point calculation per the rulebook.
  // -------------------------------------------------------------------------
  int basePoints({Wind? playerWind, Wind? dominantWind}) {
    switch (type) {
      case CombType.Chow:
        return 0;

      case CombType.Paire:
        final t = representativeTile;
        if (t.family == TileFamily.vent) {
          // Only the player's own wind or the dominant wind scores 2 pts.
          if (t.wind == playerWind || t.wind == dominantWind) return 2;
          return 0;
        }
        if (t.family == TileFamily.dragon) {
          return exposed ? 0 : 2;
        }
        // Ordinary numbered tile pair: 0 points
        return 0;

      case CombType.Pung:
        final t = representativeTile;
        if (t.family.isNumbered) {
          if (t.isMineur) return exposed ? 2 : 4;
          if (t.isMajeur) return exposed ? 4 : 8;
        }
        // Vents ou Dragons
        return exposed ? 4 : 8;

      case CombType.Kong:
        final t = representativeTile;
        if (t.family.isNumbered) {
          if (t.isMineur) return exposed ? 8 : 16;
          if (t.isMajeur) return exposed ? 16 : 32;
        }
        // Vents ou Dragons
        return exposed ? 16 : 32;
    }
  }

  // -------------------------------------------------------------------------
  // Multiplier contributed by this single combination.
  // -------------------------------------------------------------------------
  int multiplier({required Wind playerWind, required Wind dominantWind}) {
    if (type != CombType.Pung && type != CombType.Kong) return 1;
    final t = representativeTile;
    int m = 1;
    if (t.family == TileFamily.vent) {
      if (t.wind == playerWind) m *= 2;
      if (t.wind == dominantWind) m *= 2;
    }
    if (t.family == TileFamily.dragon) m *= 2;
    return m;
  }

  @override
  String toString() {
    final tileStr = tiles.map((t) => t.label).join(', ');
    final exp = exposed ? 'exposé' : 'caché';
    return '${type.name}($tileStr)[$exp]';
  }
}
