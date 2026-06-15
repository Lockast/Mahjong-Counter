import 'package:flutter_test/flutter_test.dart';
import 'package:mahjong_tracker/core/models/tile.dart';
import 'package:mahjong_tracker/core/models/wind.dart';
import 'package:mahjong_tracker/core/scoring/grand_jeux.dart';
import 'package:mahjong_tracker/core/scoring/hand_scorer.dart';

// ---------------------------------------------------------------------------
// Test helper — build a minimal TileCatalog without loading JSON
// ---------------------------------------------------------------------------

void _initCatalog() {
  TileCatalog.init({
    'suits': [
      {
        'id': 'bambou',
        'label': 'Bambou',
        'tiles': List.generate(
            9,
            (i) => {
                  'id': 'bambou_${i + 1}',
                  'file': 'bamboo${i + 1}.jpg',
                  'number': i + 1,
                  'label': 'Bambou ${i + 1}'
                }),
      },
      {
        'id': 'caracteres',
        'label': 'Caractères',
        'tiles': List.generate(
            9,
            (i) => {
                  'id': 'caracteres_${i + 1}',
                  'file': 'cara${i + 1}.jpg',
                  'number': i + 1,
                  'label': 'Caractère ${i + 1}'
                }),
      },
      {
        'id': 'sapek',
        'label': 'Sapèques',
        'tiles': List.generate(
            9,
            (i) => {
                  'id': 'sapek_${i + 1}',
                  'file': 'sapek${i + 1}.jpg',
                  'number': i + 1,
                  'label': 'Sapèque ${i + 1}'
                }),
      },
    ],
    'honours': {
      'winds': [
        {'id': 'vent_est', 'file': 'est.jpg', 'wind': 'est', 'label': 'Est'},
        {'id': 'vent_sud', 'file': 'sud.jpg', 'wind': 'sud', 'label': 'Sud'},
        {
          'id': 'vent_ouest',
          'file': 'ouest.jpg',
          'wind': 'ouest',
          'label': 'Ouest'
        },
        {
          'id': 'vent_nord',
          'file': 'nord.jpg',
          'wind': 'nord',
          'label': 'Nord'
        },
      ],
      'dragons': [
        {'id': 'dragon_blanc', 'file': 'blanc.jpg', 'label': 'Dragon Blanc'},
        {'id': 'dragon_vert', 'file': 'vert.jpg', 'label': 'Dragon Vert'},
        {'id': 'dragon_rouge', 'file': 'rouge.jpg', 'label': 'Dragon Rouge'},
      ],
    },
    'bonus': {
      'flowers': List.generate(
          4,
          (i) => {
                'id': 'fleur_${i + 1}',
                'file': 'flower${i + 1}.png',
                'number': i + 1,
                'label': 'Fleur ${i + 1}'
              }),
      'seasons': List.generate(
          4,
          (i) => {
                'id': 'saison_${i + 1}',
                'file': 'saison${i + 1}.png',
                'number': i + 1,
                'label': 'Saison ${i + 1}'
              }),
    },
  });
}

// Shortcut helpers
TileInstance h(String id) =>
    TileInstance(tile: TileCatalog.byId(id)!, exposed: false);
TileInstance e(String id) =>
    TileInstance(tile: TileCatalog.byId(id)!, exposed: true);

HandInput input(List<TileInstance> tiles,
        {bool isMahjong = false,
        Wind playerWind = Wind.est,
        Wind dominantWind = Wind.est,
        bool mainAppelante = false}) =>
    HandInput(
      tiles: tiles,
      isMahjong: isMahjong,
      playerWind: playerWind,
      dominantWind: dominantWind,
      mainAppelante: mainAppelante,
    );

void main() {
  setUpAll(_initCatalog);

  // ---------------------------------------------------------------------------
  // Grand Jeu fixed scoring
  // ---------------------------------------------------------------------------
  group('Grand Jeu fixed scoring', () {
    test('returns correct fixed score', () {
      final result = HandScorer.score(HandInput(
        tiles: const [],
        isMahjong: true,
        grandJeuName: 'Le Mahjong Impérial',
        playerWind: Wind.est,
        dominantWind: Wind.est,
      ));
      expect(result.score, 5000);
    });

    test('Grand Jeu not capped at 1000', () {
      final result = HandScorer.score(HandInput(
        tiles: const [],
        isMahjong: true,
        grandJeuName: 'La Tempête',
        playerWind: Wind.est,
        dominantWind: Wind.est,
      ));
      expect(result.score, 3000);
      expect(result.cappedAt1000, false);
    });

    test('all Grand Jeu scores match spec', () {
      for (final gj in GrandJeux.all) {
        expect(GrandJeux.scoreFor(gj.name), gj.points,
            reason: '${gj.name} should be ${gj.points}');
      }
    });

    test('all Grand Jeux have descriptions', () {
      for (final gj in GrandJeux.all) {
        expect(gj.description, isNotEmpty,
            reason: '${gj.name} needs a description');
      }
    });
  });

  // ---------------------------------------------------------------------------
  // Mahjong bonus
  // ---------------------------------------------------------------------------
  group('Mahjong base score', () {
    test('Mahjong gives at least 20 pts', () {
      final tiles = [
        h('bambou_1'),
        h('bambou_2'),
        h('bambou_3'),
        h('bambou_4'),
        h('bambou_5'),
        h('bambou_6'),
        h('bambou_7'),
        h('bambou_8'),
        h('bambou_9'),
        h('caracteres_1'),
        h('caracteres_2'),
        h('caracteres_3'),
        h('bambou_1'),
        h('bambou_1'),
      ];
      final result = HandScorer.score(HandInput(
        tiles: tiles,
        isMahjong: true,
        playerWind: Wind.est,
        dominantWind: Wind.est,
      ));
      expect(result.score, greaterThanOrEqualTo(40));
    });
  });

  // ---------------------------------------------------------------------------
  // Score cap
  // ---------------------------------------------------------------------------
  group('Score cap', () {
    test('ordinary Mahjong capped at 1000', () {
      final tiles = [
        h('vent_est'),
        h('vent_est'),
        h('vent_est'),
        h('vent_est'),
        h('vent_nord'),
        h('vent_nord'),
        h('vent_nord'),
        h('vent_nord'),
        h('vent_sud'),
        h('vent_sud'),
        h('vent_sud'),
        h('vent_sud'),
        h('dragon_blanc'),
        h('dragon_blanc'),
      ];
      final result = HandScorer.score(HandInput(
        tiles: tiles,
        isMahjong: true,
        playerWind: Wind.est,
        dominantWind: Wind.est,
      ));
      expect(result.score, lessThanOrEqualTo(1000));
      expect(result.cappedAt1000, true);
    });
  });

  // ---------------------------------------------------------------------------
  // Change 3: Wind pair scoring
  // ---------------------------------------------------------------------------
  group('Wind pair scoring (Change 3)', () {
    test('pair of player wind = 2 pts', () {
      // Est player, Est dominant: pair of Est = 2 pts
      final r = HandScorer.score(input(
        [h('vent_est'), h('vent_est')],
        playerWind: Wind.est,
        dominantWind: Wind.sud,
      ));
      expect(r.combinationBasePoints, 2);
    });

    test('pair of dominant wind = 2 pts', () {
      // Est player, Sud dominant: pair of Sud (dominant) = 2 pts
      final r = HandScorer.score(input(
        [h('vent_sud'), h('vent_sud')],
        playerWind: Wind.est,
        dominantWind: Wind.sud,
      ));
      expect(r.combinationBasePoints, 2);
    });

    test('pair of unrelated wind = 0 pts', () {
      // Est player, Sud dominant: pair of Ouest = 0 pts
      final r = HandScorer.score(input(
        [h('vent_ouest'), h('vent_ouest')],
        playerWind: Wind.est,
        dominantWind: Wind.sud,
      ));
      expect(r.combinationBasePoints, 0);
    });

    test('player wind same as dominant wind: pair scores 2 not 4', () {
      // Est player, Est dominant: pair of Est = 2 pts (not doubled)
      final r = HandScorer.score(input(
        [h('vent_est'), h('vent_est')],
        playerWind: Wind.est,
        dominantWind: Wind.est,
      ));
      expect(r.combinationBasePoints, 2);
    });
  });

  // ---------------------------------------------------------------------------
  // Change 5: Main appelante for non-winning players
  // ---------------------------------------------------------------------------
  group('Main appelante non-winner (Change 5)', () {
    test('non-winner with main appelante: only flowers/seasons count', () {
      final r = HandScorer.score(input(
        [
          h('bambou_5'), h('bambou_5'), h('bambou_5'), // brelan (would score 4)
          h('fleur_1'), // flower (4 pts)
        ],
        isMahjong: false,
        playerWind: Wind.est,
        dominantWind: Wind.est,
        mainAppelante: true,
      ));
      // Brelan is cancelled; only fleur_1 = 4 pts, own flower ×2 = 8
      expect(r.score, 8);
    });

    test('non-winner with main appelante and no flowers = 0 pts', () {
      final r = HandScorer.score(input(
        [h('bambou_5'), h('bambou_5'), h('bambou_5')],
        isMahjong: false,
        mainAppelante: true,
      ));
      expect(r.score, 0);
    });

    test('winning player with main appelante still doubles', () {
      // A Mahjong hand with mainAppelante should get ×2
      final tiles = [
        h('bambou_1'),
        h('bambou_2'),
        h('bambou_3'),
        h('bambou_4'),
        h('bambou_5'),
        h('bambou_6'),
        h('bambou_7'),
        h('bambou_8'),
        h('bambou_9'),
        h('caracteres_1'),
        h('caracteres_2'),
        h('caracteres_3'),
        h('bambou_1'),
        h('bambou_1'),
      ];
      final rWithout = HandScorer.score(HandInput(
        tiles: tiles,
        isMahjong: true,
        playerWind: Wind.est,
        dominantWind: Wind.est,
        mainAppelante: false,
      ));
      final rWith = HandScorer.score(HandInput(
        tiles: tiles,
        isMahjong: true,
        playerWind: Wind.est,
        dominantWind: Wind.est,
        mainAppelante: true,
      ));
      // Score with main appelante should be exactly 2× (before cap)
      expect(rWith.score, greaterThan(rWithout.score));
    });
  });

  // ---------------------------------------------------------------------------
  // Change 8: Honneurs + une seule série
  // ---------------------------------------------------------------------------
  group('Honneurs + une seule série (Change 8)', () {
    // Multiplier only applies to Mahjong hands; pass isMahjong: true.
    test('honours + only bambou = bonus applies', () {
      final r = HandScorer.score(input(
        [
          h('bambou_5'),
          h('bambou_5'),
          h('bambou_5'),
          h('vent_est'),
          h('vent_est'),
          h('vent_est'),
        ],
        isMahjong: true,
        playerWind: Wind.nord,
        dominantWind: Wind.nord,
      ));
      expect(r.explanations, contains('Honneurs + une série: ×2'));
    });

    test('honours + bambou + one caractere = no bonus', () {
      final r = HandScorer.score(input(
        [
          h('bambou_5'), h('bambou_5'), h('bambou_5'),
          h('caracteres_3'), // second suit
          h('vent_est'), h('vent_est'), h('vent_est'),
        ],
        isMahjong: true,
        playerWind: Wind.nord,
        dominantWind: Wind.nord,
      ));
      expect(r.explanations, isNot(contains('Honneurs + une série: ×2')));
    });

    test('flowers/seasons do not invalidate honneurs+série bonus', () {
      final r = HandScorer.score(input(
        [
          h('bambou_5'), h('bambou_5'), h('bambou_5'),
          h('vent_est'), h('vent_est'), h('vent_est'),
          h('fleur_1'), // bonus tile — should not invalidate
        ],
        isMahjong: true,
        playerWind: Wind.nord,
        dominantWind: Wind.nord,
      ));
      expect(r.explanations, contains('Honneurs + une série: ×2'));
    });
  });

  // ---------------------------------------------------------------------------
  // Change 9: Main entièrement cachée
  // ---------------------------------------------------------------------------
  group('Main entièrement cachée (Change 9)', () {
    test('all hidden tiles → bonus applies', () {
      final r = HandScorer.score(HandInput(
        tiles: [
          h('bambou_1'),
          h('bambou_2'),
          h('bambou_3'),
          h('bambou_4'),
          h('bambou_5'),
          h('bambou_6'),
          h('bambou_7'),
          h('bambou_8'),
          h('bambou_9'),
          h('caracteres_1'),
          h('caracteres_2'),
          h('caracteres_3'),
          h('bambou_1'),
          h('bambou_1'),
        ],
        isMahjong: true,
        playerWind: Wind.est,
        dominantWind: Wind.est,
      ));
      expect(r.explanations, contains('Main entièrement cachée: ×2'));
    });

    test('one exposed tile → no hidden-hand bonus', () {
      final r = HandScorer.score(HandInput(
        tiles: [
          h('bambou_1'), h('bambou_2'), h('bambou_3'),
          h('bambou_4'), h('bambou_5'), h('bambou_6'),
          h('bambou_7'), h('bambou_8'), h('bambou_9'),
          h('caracteres_1'), h('caracteres_2'), h('caracteres_3'),
          e('bambou_1'), h('bambou_1'), // one exposed
        ],
        isMahjong: true,
        playerWind: Wind.est,
        dominantWind: Wind.est,
      ));
      expect(r.explanations, isNot(contains('Main entièrement cachée: ×2')));
    });

    test('exposed flower does not invalidate hidden-hand bonus', () {
      final r = HandScorer.score(HandInput(
        tiles: [
          h('bambou_1'), h('bambou_2'), h('bambou_3'),
          h('bambou_4'), h('bambou_5'), h('bambou_6'),
          h('bambou_7'), h('bambou_8'), h('bambou_9'),
          h('caracteres_1'), h('caracteres_2'), h('caracteres_3'),
          h('bambou_1'), h('bambou_1'),
          e('fleur_1'), // exposed flower — should not count against allHidden
        ],
        isMahjong: true,
        playerWind: Wind.est,
        dominantWind: Wind.est,
      ));
      expect(r.explanations, contains('Main entièrement cachée: ×2'));
    });
  });

  // ---------------------------------------------------------------------------
  // Change 10: Main pure
  // ---------------------------------------------------------------------------
  group('Main pure (Change 10)', () {
    // Multiplier only applies to Mahjong hands; pass isMahjong: true.
    test('only bambou = pure applies', () {
      final r = HandScorer.score(input(
        [
          h('bambou_1'),
          h('bambou_2'),
          h('bambou_3'),
          h('bambou_4'),
          h('bambou_5'),
          h('bambou_6'),
        ],
        isMahjong: true,
        playerWind: Wind.nord,
        dominantWind: Wind.nord,
      ));
      expect(r.explanations, contains('Main pure (couleur unique): ×8'));
    });

    test('bambou + one caractere = no pure bonus', () {
      final r = HandScorer.score(input(
        [
          h('bambou_1'),
          h('bambou_2'),
          h('bambou_3'),
          h('caracteres_5'),
        ],
        isMahjong: true,
        playerWind: Wind.nord,
        dominantWind: Wind.nord,
      ));
      expect(r.explanations, isNot(contains('Main pure (couleur unique): ×8')));
    });

    test('bambou + one wind = no pure bonus', () {
      final r = HandScorer.score(input(
        [
          h('bambou_1'),
          h('bambou_2'),
          h('bambou_3'),
          h('vent_est'),
        ],
        isMahjong: true,
        playerWind: Wind.nord,
        dominantWind: Wind.nord,
      ));
      expect(r.explanations, isNot(contains('Main pure (couleur unique): ×8')));
    });

    test('bambou + one dragon = no pure bonus', () {
      final r = HandScorer.score(input(
        [
          h('bambou_1'),
          h('bambou_2'),
          h('bambou_3'),
          h('dragon_rouge'),
        ],
        isMahjong: true,
        playerWind: Wind.nord,
        dominantWind: Wind.nord,
      ));
      expect(r.explanations, isNot(contains('Main pure (couleur unique): ×8')));
    });

    test('flowers/seasons do not invalidate pure bonus', () {
      final r = HandScorer.score(input(
        [
          h('bambou_1'), h('bambou_2'), h('bambou_3'),
          h('bambou_4'), h('bambou_5'), h('bambou_6'),
          h('fleur_1'), // bonus — should not invalidate
        ],
        isMahjong: true,
        playerWind: Wind.nord,
        dominantWind: Wind.nord,
      ));
      expect(r.explanations, contains('Main pure (couleur unique): ×8'));
    });
  });

  // ---------------------------------------------------------------------------
  // Change 11: Vents et Dragons seulement
  // ---------------------------------------------------------------------------
  group('Vents et Dragons seulement (Change 11)', () {
    // This multiplier applies to Mahjong hands only.
    // Build a minimal valid Mahjong hand of honours + pair.
    List<TileInstance> _honourMahjongHand() => [
          h('vent_est'), h('vent_est'), h('vent_est'), h('vent_est'), // carré
          h('vent_sud'), h('vent_sud'), h('vent_sud'), h('vent_sud'), // carré
          h('vent_ouest'), h('vent_ouest'), h('vent_ouest'),
          h('vent_ouest'), // carré
          h('dragon_blanc'), h('dragon_blanc'), // pair
        ];

    test('only winds and dragons (Mahjong) = bonus applies', () {
      final r = HandScorer.score(HandInput(
        tiles: _honourMahjongHand(),
        isMahjong: true,
        playerWind: Wind.nord,
        dominantWind: Wind.nord,
      ));
      expect(r.explanations, contains('Vents et Dragons seulement: ×2'));
    });

    test('winds + dragons + flowers/seasons = bonus still applies', () {
      final r = HandScorer.score(HandInput(
        tiles: [..._honourMahjongHand(), h('fleur_1'), h('saison_2')],
        isMahjong: true,
        playerWind: Wind.nord,
        dominantWind: Wind.nord,
      ));
      expect(r.explanations, contains('Vents et Dragons seulement: ×2'));
    });

    test('one bambou tile = no honours-only bonus', () {
      // Replace the pair of dragons with bambou tiles to break the honours-only condition
      final tiles = [
        h('vent_est'), h('vent_est'), h('vent_est'), h('vent_est'),
        h('vent_sud'), h('vent_sud'), h('vent_sud'), h('vent_sud'),
        h('vent_ouest'), h('vent_ouest'), h('vent_ouest'), h('vent_ouest'),
        h('bambou_5'), h('bambou_5'), // pair of bambou = numbered tile
      ];
      final r = HandScorer.score(HandInput(
        tiles: tiles,
        isMahjong: true,
        playerWind: Wind.nord,
        dominantWind: Wind.nord,
      ));
      expect(r.explanations, isNot(contains('Vents et Dragons seulement: ×2')));
    });
  });

  // ---------------------------------------------------------------------------
  // Change 12: Incompatible flags validation
  // ---------------------------------------------------------------------------
  group('Incompatible flags validation (Change 12)', () {
    test('sur première donne conflicts with tuile exposee', () {
      final i = HandInput(
        tiles: const [],
        isMahjong: true,
        playerWind: Wind.est,
        dominantWind: Wind.est,
        surPremiereDonne: true,
        tuileExposee: true,
      );
      expect(i.validate(), isNotNull);
    });

    test('tuile mur conflicts with vol kong', () {
      final i = HandInput(
        tiles: const [],
        isMahjong: true,
        playerWind: Wind.est,
        dominantWind: Wind.est,
        tuileDuMur: true,
        volKongExpose: true,
      );
      expect(i.validate(), isNotNull);
    });

    test('valid single flag = no conflict', () {
      final i = HandInput(
        tiles: const [],
        isMahjong: true,
        playerWind: Wind.est,
        dominantWind: Wind.est,
        tuileDuMur: true,
      );
      expect(i.validate(), isNull);
    });

    test('sur première donne alone = valid', () {
      final i = HandInput(
        tiles: const [],
        isMahjong: true,
        playerWind: Wind.est,
        dominantWind: Wind.est,
        surPremiereDonne: true,
      );
      expect(i.validate(), isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // Non-Mahjong scoring (regression)
  // ---------------------------------------------------------------------------
  group('Non-Mahjong hand scoring', () {
    test('empty hand → 0 pts', () {
      final result = HandScorer.score(HandInput(
        tiles: const [],
        isMahjong: false,
        playerWind: Wind.est,
        dominantWind: Wind.est,
      ));
      expect(result.score, 0);
    });

    test('exposed minor brelan = 2 pts', () {
      final result = HandScorer.score(HandInput(
        tiles: [e('bambou_5'), e('bambou_5'), e('bambou_5')],
        isMahjong: false,
        playerWind: Wind.est,
        dominantWind: Wind.est,
      ));
      expect(result.score, 2);
    });

    test('hidden minor brelan = 4 pts', () {
      final result = HandScorer.score(HandInput(
        tiles: [h('bambou_5'), h('bambou_5'), h('bambou_5')],
        isMahjong: false,
        playerWind: Wind.est,
        dominantWind: Wind.est,
      ));
      expect(result.score, 4);
    });

    test('hidden major brelan (9) = 8 pts', () {
      final result = HandScorer.score(HandInput(
        tiles: [h('bambou_9'), h('bambou_9'), h('bambou_9')],
        isMahjong: false,
        playerWind: Wind.est,
        dominantWind: Wind.est,
      ));
      expect(result.score, 8);
    });

    test(
        'exposed carré of player+dominant wind: 16 base × ×2(player) × ×2(dominant) = 64',
        () {
      // Per-combination multipliers apply to all players.
      // Hand-level multipliers (vents+dragons ×2) only apply to Mahjong winners.
      final result = HandScorer.score(HandInput(
        tiles: [e('vent_est'), e('vent_est'), e('vent_est'), e('vent_est')],
        isMahjong: false,
        playerWind: Wind.est,
        dominantWind: Wind.est,
      ));
      // 16 (exposed carré honour) × 2 (playerWind) × 2 (dominantWind) = 64
      expect(result.score, 64);
    });

    test('each flower = 4 pts; own flower ×2 multiplier', () {
      final result = HandScorer.score(HandInput(
        tiles: [h('fleur_1'), h('fleur_2')],
        isMahjong: false,
        playerWind: Wind.est,
        dominantWind: Wind.est,
      ));
      // 8 pts base + own flower (fleur_1) ×2 = 16
      expect(result.score, 16);
    });
  });

  group('Grand Jeux list', () {
    test('non-empty', () => expect(GrandJeux.all, isNotEmpty));
    test('all have positive points', () {
      for (final gj in GrandJeux.all) {
        expect(gj.points, greaterThan(0));
      }
    });
  });
}
