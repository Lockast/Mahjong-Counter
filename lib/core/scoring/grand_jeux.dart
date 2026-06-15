/// Fixed-score Grand Jeux. A Grand Jeu bypasses all normal scoring and
/// multipliers; its score is returned as-is (no 1000-point cap).
class GrandJeux {
  GrandJeux._();

  static const List<GrandJeu> all = [
    GrandJeu(
      'La Main des paires',
      500,
      '7 paires quelconques.',
      '7 arbitrary pairs.',
      'The Pair Hand',
    ),
    GrandJeu(
      'Les 7 Lanternes du Palais',
      500,
      '1 suite de 1 à 7, 1 tuile formant la paire 1 pung de dragons, 1 pung de vent du joueur.',
      '1 run of 1 to 7, 1 pair tile, 1 dragon pung, 1 player\'s wind pung.',
      'The 7 Palace Lanterns',
    ),
    GrandJeu(
      'Les Chow Venteux',
      500,
      '1 chow de chaque série, les 4 vents, 1 cinquième vent quelconque.',
      '1 chow from each suit, all 4 winds, 1 additional wind.',
      'The Windy Chows',
    ),
    GrandJeu(
      'Le Chow Royal',
      600,
      '3 chow de séries différentes, les 3 dragons, 1 paire de vent du joueur.',
      '3 chows from different suits, all 3 dragons, 1 player\'s wind pair.',
      'The Royal Chow',
    ),
    GrandJeu(
      'La Main Chinoise',
      700,
      '1 suite de 2 à 8, 1 tuile format la paire, 1 pung de 1 et de 9.',
      '1 run of 2 to 8, 1 pair tile, 1 pung of 1s and 1 pung of 9s.',
      'The Chinese Hand',
    ),
    GrandJeu(
      'Le Joueur Maladroit',
      700,
      '1 suite de 1 à 7, les 4 vents, 1 pung de dragons.',
      '1 run of 1 to 7, all 4 winds, 1 dragon pung.',
      'The Clumsy Player',
    ),
    GrandJeu(
      'La Main Pleine de 9 pièces',
      700,
      'Tous les 1, tous les 9, 1 suite de 2 à 8, 1 tuile formant la paire avec une des tuiles de la suite.',
      'All 1s, all 9s, 1 run of 2 to 8, 1 pair tile taken from within the run.',
      'The Nine-Tile Full Hand',
    ),
    GrandJeu(
      'Les Pung Venteux',
      800,
      '1 pung de chaque série, les 4 vents, 1 cinquième vent quelconque.',
      '1 pung from each suit, all 4 winds, 1 additional wind.',
      'The Windy Pungs',
    ),
    GrandJeu(
      'Le Petit Serpent',
      1000,
      '1 suite de 1 à 9, les 4 vents, un honneur supérieur (dragon) quelconque.',
      '1 run of 1 to 9, all 4 winds, any dragon.',
      'The Little Serpent',
    ),
    GrandJeu(
      'Les Paires Venteuses',
      1000,
      '1 paire chaque vent, 1 paire de chaque série.',
      '1 pair for each wind, 1 pair from each suit.',
      'The Windy Pairs',
    ),
    GrandJeu(
      'Le Jardin de Gretos',
      1100,
      '1 suite de 1 à 7, les 3 dragon, les 4 vents.',
      '1 run of 1 to 7, all 3 dragons, all 4 winds.',
      'The Garden of Gretos',
    ),
    GrandJeu(
      'Les Grands Frères',
      1200,
      '1 suite de 1 à 9, 1 pung d\'honneurs, 1 paire de vent du joueur.',
      '1 run of 1 to 9, 1 honours pung, 1 player\'s wind pair.',
      'The Elder Brothers',
    ),
    GrandJeu(
      "La Main d'Opaline",
      1300,
      '3 pung de cercles, 1 pung de dragons blancs, 1 paire de cercles.',
      '3 circles pungs, 1 white dragon pung, 1 circles pair.',
      "The Opal Hand",
    ),
    GrandJeu(
      'La Main de Jade',
      1300,
      '3 pung de bambous, 1 pung de dragons verts, 1 paire de bambous.',
      '3 bamboo pungs, 1 green dragon pung, 1 bamboo pair.',
      'The Jade Hand',
    ),
    GrandJeu(
      'La Main de Corail',
      1300,
      '6 paires différences de la même série, 1 paire du dragon associé.',
      '6 different pairs from the same suit, 1 pair of the matching dragon.',
      'The Coral Hand',
    ),
    GrandJeu(
      'Les Paires de Shozum',
      1300,
      '6 paires différences de la même série, 1 paire du dragon associé.',
      '6 different pairs from the same suit, 1 pair of the matching dragon.',
      'The Shozum Pairs',
    ),
    GrandJeu(
      'La Main de Diamant (grand serpent)',
      1400,
      '1 suite de 1 à 9 cercles, 1 pung de dragons blancs, 1 paire d\'honneurs.',
      '1 run of 1 to 9 in circles, 1 white dragon pung, 1 honours pair.',
      'The Diamond Hand (great serpent)',
    ),
    GrandJeu(
      "La Main d'Émeraude (grand serpent)",
      1400,
      '1 suite de 1 à 9 bambous, 1 pung de dragons verts, 1 paire d\'honneurs.',
      '1 run of 1 to 9 in bamboo, 1 green dragon pung, 1 honours pair.',
      "The Emerald Hand (great serpent)",
    ),
    GrandJeu(
      'La Main de Rubis (grand serpent)',
      1400,
      '1 suite de 1 à 9 caractères, 1 pung de dragons rouges, 1 paire d\'honneurs.',
      '1 run of 1 to 9 in characters, 1 red dragon pung, 1 honours pair.',
      'The Ruby Hand (great serpent)',
    ),
    GrandJeu(
      'Le Serpentin des 4 Vents',
      1400,
      '1 suite alternée des 3 séries, les 4 vents, 1 honneur quelconque.',
      '1 alternating run across 3 suits, all 4 winds, any honour.',
      'The 4-Wind Serpent',
    ),
    GrandJeu(
      'Le Triangle Venteux',
      1400,
      '3 pung identiques en valeur, les 4 vents, 1 cinquième vent quelconque.',
      '3 pungs of the same value, all 4 winds, 1 additional wind.',
      'The Windy Triangle',
    ),
    GrandJeu(
      'Le Serpentin Royal',
      1500,
      '1 suite alternée des 3 séries, les 3 dragons, 1 paire de vent du joueur.',
      '1 alternating run across 3 suits, all 3 dragons, 1 player\'s wind pair.',
      'The Royal Serpent',
    ),
    GrandJeu(
      'Les 13 Lanternes Merveilleuses',
      1600,
      'Tous les honneurs (1 et 9 compris), 1 quatorzième honneur quelconque.',
      'All honours (including 1s and 9s), any 14th honour tile.',
      'The 13 Wondrous Lanterns',
    ),
    GrandJeu(
      'Les 7 Muses du Poète Chinois',
      1700,
      '7 paires de vents, dragons, 1 ou 9.',
      '7 pairs of winds, dragons, 1s or 9s.',
      'The 7 Muses of the Chinese Poet',
    ),
    GrandJeu(
      'Le Pung Royal',
      1800,
      '3 pung identiques en valeur, les 3 dragons, 1 paire du vent du joueur.',
      '3 pungs of the same value, all 3 dragons, 1 player\'s wind pair.',
      'The Royal Pung',
    ),
    GrandJeu(
      'Les 4 Bonheurs Domestiques',
      2000,
      '1 pung de chaque vent, 1 paire quelconque.',
      '1 pung of each wind, any pair.',
      'The 4 Domestic Joys',
    ),
    GrandJeu(
      'Les 3 Grands Apôtres',
      2000,
      '1 brelan de chaque dragon, une suite, une paire de la même série.',
      '1 pung of each dragon, 1 run and 1 pair from the same suit.',
      'The 3 Great Apostles',
    ),
    GrandJeu(
      'Les 3 Fils Adoptifs du Dragon',
      2200,
      '3 pung identiques, 1 pung de dragons rouges, 1 paire de vents.',
      '3 identical pungs, 1 red dragon pung, 1 wind pair.',
      'The 3 Adopted Sons of the Dragon',
    ),
    GrandJeu(
      'Le Triangle Éternel (ou Le Ying et le Yang)',
      2500,
      '1 paire de chaque honneur (vents et dragons).',
      '1 pair of each honour (winds and dragons).',
      'The Eternal Triangle (or Yin and Yang)',
    ),
    GrandJeu(
      'Les Ennemis',
      2500,
      '2 brelans de vents opposés, 2 Brelans terminaux de la même série, 2 vents complémentaires.',
      '2 pungs of opposing winds, 2 terminal pungs of the same suit, 2 complementary winds.',
      'The Enemies',
    ),
    GrandJeu(
      'La Tempête',
      3000,
      '2 pung de dragons, 1 paire de chaque vents.',
      '2 dragon pungs, 1 pair of each wind.',
      'The Storm',
    ),
    GrandJeu(
      'La Grande Main Verte',
      3500,
      '3 pung pairs de bambous, 1 pung de dragons verts, 1 paire de bambous pairs.',
      '3 pungs of even bamboos, 1 green dragon pung, 1 pair of even bamboos.',
      'The Great Green Hand',
    ),
    GrandJeu(
      'Le Souffle du Dragon',
      4000,
      '1 pung de chaque dragon, les 4 vents, 1 cinquième vent quelconque.',
      '1 pung of each dragon, all 4 winds, 1 additional wind.',
      "The Dragon's Breath",
    ),
    GrandJeu(
      'Le Mahjong Impérial',
      5000,
      '3 pung de dragons, une séquence de dragons, une paire de vents.',
      '3 dragon pungs, 1 dragon sequence, 1 wind pair.',
      'The Imperial Mahjong',
    ),
  ];

  static final Map<String, int> _scores = {
    for (final gj in all) gj.name: gj.points,
  };

  static int? scoreFor(String name) => _scores[name];

  /// Returns the display name for a stored French name, in the requested locale.
  static String displayName(String frName, {required bool isEn}) {
    if (!isEn) return frName;
    try {
      return all.firstWhere((g) => g.name == frName).nameEn;
    } catch (_) {
      return frName;
    }
  }
}

class GrandJeu {
  final String name;
  final int points;
  final String description;
  final String descriptionEn;
  final String nameEn;

  const GrandJeu(this.name, this.points, this.description, this.descriptionEn,
      this.nameEn);
}
