import '../l10n/strings.dart';
import '../models/wind.dart';
import '../models/tile.dart';
import '../models/combination.dart';
import 'grand_jeux.dart';
import 'combination_detector.dart';

// ---------------------------------------------------------------------------
// Input / Output
// ---------------------------------------------------------------------------

class HandInput {
  final List<TileInstance> tiles;
  final bool isMahjong;
  final String? grandJeuName;

  // Mahjong-specific special conditions
  final bool tuileExposee; // Mah-Jong par une tuile exposée
  final bool tuileDuMur; // Mah-Jong avec une tuile provenant du Mur
  final bool pecheLune; // Pêcher la lune au fond de la mer
  final bool volKongExpose; // Vol kong exposé
  final bool
      mainAppelante; // Main appelante (gagnant: ×2 ; perdant: annulation)
  final bool surPremiereDonne; // Sur première donne

  final Wind playerWind;
  final Wind dominantWind;

  final AppLocale locale;

  const HandInput({
    required this.tiles,
    required this.isMahjong,
    this.grandJeuName,
    this.tuileExposee = false,
    this.tuileDuMur = false,
    this.pecheLune = false,
    this.volKongExpose = false,
    this.mainAppelante = false,
    this.surPremiereDonne = false,
    required this.playerWind,
    required this.dominantWind,
    this.locale = AppLocale.fr,
  });

  List<String> get specialFlags {
    final flags = <String>[];
    if (tuileExposee) flags.add('tuileExposee');
    if (tuileDuMur) flags.add('tuileDuMur');
    if (pecheLune) flags.add('pecheLune');
    if (volKongExpose) flags.add('volKongExpose');
    if (mainAppelante) flags.add('mainAppelante');
    if (surPremiereDonne) flags.add('surPremiereDonne');
    return flags;
  }

  /// Validates that mutually exclusive flags are not simultaneously set.
  /// Returns null if valid, or an error message if invalid.
  String? validate() {
    if (surPremiereDonne &&
        (tuileExposee || tuileDuMur || pecheLune || volKongExpose)) {
      return 'Sur première donne est incompatible avec les autres bonus.';
    }
    if (tuileExposee && (tuileDuMur || pecheLune)) {
      return 'Tuile exposée est incompatible avec Tuile mur, Pêcher la lune.';
    }
    if (tuileDuMur && volKongExpose) {
      return 'Tuile mur et Vol kong exposé sont incompatibles.';
    }
    if (pecheLune && volKongExpose) {
      return 'Pêcher la lune et Vol kong exposé sont incompatibles.';
    }
    return null;
  }
}

class HandResult {
  final int score;
  final int combinationBasePoints;
  final int bonusTilePoints;
  final int mahjongBonusPoints;
  final int totalBasePoints;
  final int multiplier;
  final bool cappedAt1000;
  final List<Combination> combinations;
  final List<String> explanations;

  const HandResult({
    required this.score,
    required this.combinationBasePoints,
    required this.bonusTilePoints,
    required this.mahjongBonusPoints,
    required this.totalBasePoints,
    required this.multiplier,
    required this.cappedAt1000,
    required this.combinations,
    required this.explanations,
  });
}

// ---------------------------------------------------------------------------
// HandScorer — pure scoring logic, no UI dependencies
// ---------------------------------------------------------------------------

class HandScorer {
  HandScorer._();

  static HandResult score(HandInput input) {
    final isEn = input.locale == AppLocale.en;

    // ---- Grand Jeu: fixed score, no further processing ----
    if (input.grandJeuName != null) {
      final pts = GrandJeux.scoreFor(input.grandJeuName!) ?? 0;
      final displayName =
          GrandJeux.displayName(input.grandJeuName!, isEn: isEn);
      return HandResult(
        score: pts,
        combinationBasePoints: pts,
        bonusTilePoints: 0,
        mahjongBonusPoints: 0,
        totalBasePoints: pts,
        multiplier: 1,
        cappedAt1000: false,
        combinations: const [],
        explanations: [
          isEn
              ? 'Special hand: $displayName = $pts pts'
              : 'Grand Jeu : $displayName = $pts pts'
        ],
      );
    }

    // ---- Detect combinations ----
    final detection = input.isMahjong
        ? CombinationDetector.detectMahjong(input.tiles)
        : CombinationDetector.detectRegular(input.tiles);

    // If multiple valid Mahjong decompositions exist, pick the highest-scoring one.
    List<Combination> bestCombinations = detection.combinations;
    if (detection.allDecompositions != null &&
        detection.allDecompositions!.length > 1) {
      bestCombinations = _pickBestDecomposition(
        detection.allDecompositions!,
        detection.bonusTiles,
        input,
      );
    }

    return _scoreFromCombinations(
      bestCombinations,
      detection.bonusTiles,
      input,
    );
  }

  // ---------------------------------------------------------------------------
  // Core scoring
  // ---------------------------------------------------------------------------

  static HandResult _scoreFromCombinations(
    List<Combination> combinations,
    List<TileInstance> bonusTiles,
    HandInput input,
  ) {
    final explanations = <String>[];
    final isEn = input.locale == AppLocale.en;
    String t(String fr, String en) => isEn ? en : fr;

    // ---- Non-winning "main appelante": only flowers/seasons count (Change 5) ----
    if (input.mainAppelante && !input.isMahjong) {
      final bonusPtsOnly = bonusTiles.length * 4;
      explanations.add(t(
        'Main appelante sans Mah-Jong : seules les fleurs/saisons comptent.',
        'Calling hand without Mah-Jong: only flowers/seasons count.',
      ));
      if (bonusPtsOnly > 0) {
        explanations.add(t(
          'Fleurs/Saisons (${bonusTiles.length} × 4): $bonusPtsOnly pts',
          'Flowers/Seasons (${bonusTiles.length} × 4): $bonusPtsOnly pts',
        ));
      }
      // Still apply flower/season ownership multiplier (applies to all players)
      int m =
          _flowerMultiplier(bonusTiles, input.playerWind, explanations, isEn);
      final score = bonusPtsOnly * m;
      return HandResult(
        score: score,
        combinationBasePoints: 0,
        bonusTilePoints: bonusPtsOnly,
        mahjongBonusPoints: 0,
        totalBasePoints: bonusPtsOnly,
        multiplier: m,
        cappedAt1000: false,
        combinations: combinations,
        explanations: explanations,
      );
    }

    // ---- 1. Combination base points ----
    int combPts = 0;
    for (final c in combinations) {
      final pts = c.basePoints(
          playerWind: input.playerWind, dominantWind: input.dominantWind);
      combPts += pts;
      if (pts > 0) {
        explanations
            .add('${c.type.name} ${c.representativeTile.label}: $pts pts');
      }
    }

    // ---- 2. Flower / season points (4 pts each) ----
    int bonusPts = bonusTiles.length * 4;
    if (bonusPts > 0) {
      explanations.add(t(
        'Fleurs/Saisons (${bonusTiles.length} × 4): $bonusPts pts',
        'Flowers/Seasons (${bonusTiles.length} × 4): $bonusPts pts',
      ));
    }

    // ---- 3. Mahjong bonuses ----
    int mahjongBonusPts = 0;
    if (input.isMahjong) {
      mahjongBonusPts += 20;
      explanations.add('Mah-Jong: +20 pts');

      final sets = combinations.where((c) => c.type != CombType.Paire).toList();
      final allSuites =
          sets.isNotEmpty && sets.every((c) => c.type == CombType.Chow);
      final allBrelansCarre = sets.isNotEmpty &&
          sets.every((c) => c.type == CombType.Pung || c.type == CombType.Kong);

      if (allSuites && sets.length == 4) {
        mahjongBonusPts += 10;
        explanations
            .add(t('4 suites + Paire: +10 pts', '4 Chows + Pair: +10 pts'));
      }
      if (allBrelansCarre && sets.length == 4) {
        mahjongBonusPts += 10;
        explanations.add(t('4 brelans/carrés + Paire: +10 pts',
            '4 Pungs/Kongs + Pair: +10 pts'));
      }
      if (combPts == 0 && bonusPts == 0) {
        mahjongBonusPts += 10;
        explanations.add(
            t('Main ne vaut rien: +10 pts', 'Hand worth nothing: +10 pts'));
      }
      if (input.tuileExposee) {
        mahjongBonusPts += 10;
        explanations.add(t('Tuile exposée: +10 pts', 'Exposed tile: +10 pts'));
      }
      if (input.tuileDuMur) {
        mahjongBonusPts += 2;
        explanations.add(t('Tuile du mur: +2 pts', 'Wall tile: +2 pts'));
      }
    }

    final totalBase = combPts + bonusPts + mahjongBonusPts;

    // ---- 4. Multipliers ----
    int multiplier = 1;

    // Use raw non-bonus tiles for predicate checks (Bugs 8-11).
    // Checking raw tiles avoids detector artefacts where leftover exposed
    // tiles are reclassified as hidden.
    final rawNonBonus =
        input.tiles.where((t) => !t.tile.family.isBonus).toList();
    final rawTiles = rawNonBonus.map((t) => t.tile).toSet().isEmpty
        ? <Tile>[]
        : rawNonBonus.map((t) => t.tile).toList();
    final rawSuits =
        rawTiles.where((t) => t.family.isNumbered).map((t) => t.family).toSet();
    final rawHasHonours = rawTiles.any((t) => t.family.isHonneur);

    if (input.isMahjong) {
      final sets = combinations.where((c) => c.type != CombType.Paire).toList();
      final hasSuite = sets.any((c) => c.type == CombType.Chow);

      if (!hasSuite && sets.isNotEmpty) {
        multiplier *= 2;
        explanations.add(t('Sans Chow: ×2', 'No Chows: ×2'));
      }
      if (input.pecheLune) {
        multiplier *= 2;
        explanations.add(t('Pêcher la lune: ×2', 'Moon from deep: ×2'));
      }
      if (input.volKongExpose) {
        multiplier *= 2;
        explanations.add(t('Vol kong exposé: ×2', 'Steal kong: ×2'));
      }
      if (input.mainAppelante) {
        multiplier *= 2;
        explanations.add(t('Main appelante: ×2', 'Calling hand: ×2'));
      }
      if (input.surPremiereDonne) {
        multiplier *= 8;
        explanations.add(t('Première donne: ×8', 'First deal: ×8'));
      }

      // Change 9: all non-bonus tiles must be hidden (check raw tiles)
      final allHidden = rawNonBonus.every((ti) => !ti.exposed);
      if (allHidden && rawNonBonus.isNotEmpty) {
        multiplier *= 2;
        explanations
            .add(t('Main entièrement cachée: ×2', 'Fully concealed hand: ×2'));
      }

      // Change 11: only honours (no numbered tiles at all, excluding bonus)
      if (rawTiles.isNotEmpty && !rawTiles.any((ti) => ti.family.isNumbered)) {
        multiplier *= 2;
        explanations.add(
            t('Vents et Dragons seulement: ×2', 'Winds and Dragons only: ×2'));
      }

      // Change 10: pure hand — one single numbered suit, no honours
      if (rawSuits.length == 1 && !rawHasHonours) {
        multiplier *= 8;
        explanations.add(
            t('Main pure (couleur unique): ×8', 'Pure hand (one suit): ×8'));
      }
    }

    // Change 8: honours + exactly one numbered suit
    if (rawSuits.length == 1 && rawHasHonours) {
      multiplier *= 2;
      explanations.add(t('Honneurs + une série: ×2', 'Honours + one suit: ×2'));
    }

    // Per-combination multipliers (wind/dragon brelans/carrés)
    for (final c in combinations) {
      final m = c.multiplier(
          playerWind: input.playerWind, dominantWind: input.dominantWind);
      if (m > 1) {
        multiplier *= m;
        final ti = c.representativeTile;
        if (ti.family == TileFamily.vent) {
          if (ti.wind == input.playerWind) {
            explanations.add(t('${c.type.name} vent du joueur: ×2',
                '${c.type.name} player wind: ×2'));
          }
          if (ti.wind == input.dominantWind) {
            explanations.add(t('${c.type.name} vent dominant: ×2',
                '${c.type.name} dominant wind: ×2'));
          }
        }
        if (ti.family == TileFamily.dragon) {
          explanations.add(
              t('${c.type.name} de dragon: ×2', '${c.type.name} dragon: ×2'));
        }
      }
    }

    // Flower / season ownership multipliers (applies to all players)
    multiplier *=
        _flowerMultiplier(bonusTiles, input.playerWind, explanations, isEn);

    // ---- 5. Apply multiplier and cap ----
    int finalScore = totalBase * multiplier;
    bool capped = false;
    if (finalScore > 1000 && input.grandJeuName == null) {
      finalScore = 1000;
      capped = true;
      explanations
          .add(t('Score plafonné à 1000 pts', 'Score capped at 1000 pts'));
    }

    return HandResult(
      score: finalScore,
      combinationBasePoints: combPts,
      bonusTilePoints: bonusPts,
      mahjongBonusPoints: mahjongBonusPts,
      totalBasePoints: totalBase,
      multiplier: multiplier,
      cappedAt1000: capped,
      combinations: combinations,
      explanations: explanations,
    );
  }

  /// Returns the flower/season ownership multiplier (≥1).
  /// Applies to all players, Mahjong or not.
  static int _flowerMultiplier(
    List<TileInstance> bonusTiles,
    Wind playerWind,
    List<String> explanations,
    bool isEn,
  ) {
    String t(String fr, String en) => isEn ? en : fr;
    final playerWindNum = playerWind.number;
    final hasOwnFleur = bonusTiles.any((i) =>
        i.tile.family == TileFamily.fleur && i.tile.number == playerWindNum);
    final hasOwnSaison = bonusTiles.any((i) =>
        i.tile.family == TileFamily.saison && i.tile.number == playerWindNum);
    final allFleurs = [1, 2, 3, 4].every((n) => bonusTiles
        .any((i) => i.tile.family == TileFamily.fleur && i.tile.number == n));
    final allSaisons = [1, 2, 3, 4].every((n) => bonusTiles
        .any((i) => i.tile.family == TileFamily.saison && i.tile.number == n));
    if (allFleurs) {
      explanations.add(t('Les 4 Fleurs: ×16', 'All 4 Flowers: ×16'));
      return 16;
    } else if (allSaisons) {
      explanations.add(t('Les 4 Saisons: ×16', 'All 4 Seasons: ×16'));
      return 16;
    } else if (hasOwnFleur && hasOwnSaison) {
      explanations.add(
          t('Fleur et Saison du joueur: ×4', "Player's Flower and Season: ×4"));
      return 4;
    } else if (hasOwnFleur || hasOwnSaison) {
      explanations.add(
          t('Fleur ou Saison du joueur: ×2', "Player's Flower or Season: ×2"));
      return 2;
    }
    return 1;
  }

  static List<Combination> _pickBestDecomposition(
    List<List<Combination>> decomps,
    List<TileInstance> bonusTiles,
    HandInput input,
  ) {
    List<Combination>? best;
    int bestScore = -1;
    for (final d in decomps) {
      final r = _scoreFromCombinations(d, bonusTiles, input);
      if (r.score > bestScore) {
        bestScore = r.score;
        best = d;
      }
    }
    return best ?? decomps.first;
  }
}
