import '../models/wind.dart';

enum AppLocale { fr, en }

class AppStrings {
  const AppStrings._(this.locale);

  final AppLocale locale;

  static const fr = AppStrings._(AppLocale.fr);
  static const en = AppStrings._(AppLocale.en);

  bool get isEn => locale == AppLocale.en;

  // ---- Wind ----

  String windLabel(Wind wind) {
    if (!isEn) return wind.label;
    return switch (wind) {
      Wind.est => 'East',
      Wind.sud => 'South',
      Wind.ouest => 'West',
      Wind.nord => 'North',
    };
  }

  // ---- Navigation ----

  String get navPlay => isEn ? 'Play' : 'Jouer';
  String get navHistory => isEn ? 'History' : 'Historique';
  String get navPlayers => isEn ? 'Players' : 'Joueurs';
  String get navInfo => 'Info';

  // ---- General ----

  String get errorPrefix => isEn ? 'Error: ' : 'Erreur : ';
  String get cancel => isEn ? 'Cancel' : 'Annuler';
  String get ok => 'OK';
  String get pts => 'pts';
  String get points => isEn ? 'points' : 'points';

  // ---- Language picker ----

  String get langPickerTitle =>
      isEn ? 'Choose your language' : 'Choisissez votre langue';
  String get langPickerSubtitle =>
      isEn ? 'Choisissez votre langue' : 'Choose your language';

  // ---- Jouer screen ----

  String get mahjongTitle => 'Mah-Jong';
  String get noGameInProgress =>
      isEn ? 'No game in progress' : 'Aucune partie en cours';
  String get startNewGameHint => isEn
      ? 'Start a new game to play.'
      : 'Commencez une nouvelle partie pour jouer.';
  String get newGame => isEn ? 'New game' : 'Nouvelle partie';

  // ---- Game setup screen ----

  String get newGameTitle => isEn ? 'New game' : 'Nouvelle partie';
  String get playerNames => isEn ? 'Player names' : 'Noms des joueurs';
  String playerN(int n) => isEn ? 'Player $n' : 'Joueur $n';
  String playerWindHint(String windLabelStr) =>
      isEn ? '$windLabelStr player name' : 'Nom du joueur $windLabelStr';
  String get pleaseEnterName =>
      isEn ? 'Please enter a name.' : 'Veuillez entrer un nom.';
  String get startButton => isEn ? 'Start' : 'Commencer';

  // ---- Game score screen ----

  String get endGame => isEn ? 'End game' : 'Terminer la partie';
  String get endGameConfirmTitle => isEn ? 'End game' : 'Terminer la partie';
  String get endGameConfirmBody => isEn
      ? 'Do you really want to end this game?'
      : 'Voulez-vous vraiment terminer cette partie ?';
  String get end => isEn ? 'End' : 'Terminer';
  String get noTurnsPlayed => isEn
      ? 'No turns played.\nTap + to start.'
      : 'Aucun tour joué.\nAppuyez sur + pour commencer.';
  String get newTurnTooltip => isEn ? 'New turn' : 'Nouveau tour';
  String turnWind(int n, String windSymbol, String windLabelStr) => isEn
      ? 'Turn $n  ·  Wind $windSymbol $windLabelStr'
      : 'Tour $n  ·  Vent $windSymbol $windLabelStr';

  // ---- Turn input screen ----

  String turnN(int n) => isEn ? 'Turn $n' : 'Tour $n';
  String get windColon => isEn ? 'Wind:' : 'Vent :';
  String get toEnter => isEn ? 'Enter' : 'À saisir';
  String get onlyOneMahjong => isEn
      ? 'Only one player can Mah-Jong.'
      : 'Un seul joueur peut faire Mah-Jong.';
  String get pleasePickMahjong => isEn
      ? 'Please select the Mah-Jong player.'
      : 'Veuillez choisir le joueur qui a fait Mah-Jong.';
  String get validateTurn => isEn ? 'Validate turn' : 'Valider le tour';

  // ---- Hand input screen ----

  String get callingHand => isEn ? 'Calling hand' : 'Main appelante';
  String get winnerScoreDouble =>
      isEn ? 'Winner: score ×2' : 'Gagnant : score ×2';
  String get loserFlowersOnly => isEn
      ? 'Loser: only flowers/seasons count'
      : 'Perdant : seules les fleurs/saisons comptent';
  String get handType => isEn ? 'Hand type' : 'Type de main';
  String get grandJeuLabel => isEn ? 'Grand Jeu' : 'Grand Jeu';
  String get mahjongBonuses => isEn ? 'Mah-Jong Bonuses' : 'Bonus Mah-Jong';
  String get incompatibleOptions => isEn
      ? 'Some options are mutually exclusive.'
      : 'Certaines options sont incompatibles entre elles.';
  String get exposedTile => isEn ? 'Exposed tile' : 'Tuile exposée';
  String get wallTile => isEn ? 'Wall tile' : 'Tuile mur';
  String get moonFromDeep => isEn ? 'Moon from deep' : 'Pêcher la lune';
  String get stealKong => isEn ? 'Steal kong' : 'Vol kong exposé';
  String get firstDeal => isEn ? 'First deal' : 'Première donne';
  String tilesCount(int n, int max) =>
      isEn ? 'Tiles ($n/$max)' : 'Tuiles ($n/$max)';
  String get tapTilesToSelect => isEn
      ? 'Tap tiles to select them'
      : 'Appuyez sur les tuiles pour les sélectionner';
  String get undoLast => isEn ? 'Undo last' : 'Annuler dernière';
  String get clearAll => isEn ? 'Clear all' : 'Tout effacer';
  String get modeLabel => isEn ? 'Mode: ' : 'Mode : ';
  String get hidden => isEn ? 'Hidden' : 'Caché';
  String get exposed => isEn ? 'Exposed' : 'Exposé';
  String get chooseGrandJeu =>
      isEn ? 'Choose a Grand Jeu' : 'Choisir un Grand Jeu';
  String get calculateScore => isEn ? 'Calculate score' : 'Calculer le score';
  String confirmScore(int score) =>
      isEn ? 'Confirm — $score pts' : 'Confirmer — $score pts';
  String get confirmButton => isEn ? 'Confirm' : 'Confirmer';
  String get scoreLabel => isEn ? 'Score: ' : 'Score : ';
  String get cappedLabel => isEn ? '(capped)' : '(plafonné)';

  // Tile family labels
  String get familyBamboo => isEn ? 'Bamboo' : 'Bambou';
  String get familyCharacters => isEn ? 'Characters' : 'Caractères';
  String get familyCircles => isEn ? 'Circles' : 'Sapèques';
  String get familyWinds => isEn ? 'Winds' : 'Vents';
  String get familyDragons => isEn ? 'Dragons' : 'Dragons';
  String get familyFlowers => isEn ? 'Flowers' : 'Fleurs';
  String get familySeasons => isEn ? 'Seasons' : 'Saisons';

  // ---- History screen ----

  String get historyTitle => isEn ? 'History' : 'Historique';
  String get noGamesRecorded =>
      isEn ? 'No games recorded.' : 'Aucune partie enregistrée.';
  String get inProgress => isEn ? 'In progress' : 'En cours';
  String turnsCount(int n) => isEn ? '$n turn(s)' : '$n tour(s)';
  String get tours => isEn ? 'turns' : 'tours';

  // ---- Game detail screen ----

  String get resumeButton => isEn ? 'Resume' : 'Reprendre';
  String get colPlayer => isEn ? 'Player' : 'Joueur';
  String get colHand => isEn ? 'Hand' : 'Main';
  String get colGain => isEn ? 'Gain' : 'Gain';
  String get colTotal => isEn ? 'Total' : 'Total';
  String windHeader(String symbol, String labelStr) =>
      isEn ? 'Wind $symbol $labelStr' : 'Vent $symbol $labelStr';

  // ---- Players screen ----

  String get playersTitle => isEn ? 'Players' : 'Joueurs';
  String get noPlayersRecorded =>
      isEn ? 'No players recorded.' : 'Aucun joueur enregistré.';
  String playerSubtitle(int n, String avg) =>
      isEn ? '$n game(s) · Avg. $avg pts' : '$n partie(s) · Moy. $avg pts';
  String get rankings => isEn ? 'Rankings' : 'Classements';
  String get finalScores => isEn ? 'Final scores' : 'Scores finaux';
  String get average => isEn ? 'Average' : 'Moyenne';
  String get median => isEn ? 'Median' : 'Médiane';
  String get grandJeuxAchieved =>
      isEn ? 'Grand Jeux achieved' : 'Grand Jeux réalisés';
  String get notEnoughData =>
      isEn ? 'Not enough data yet.' : 'Pas encore assez de données.';
  String ordinalSuffix(int n) => isEn
      ? switch (n) { 1 => 'st', 2 => 'nd', 3 => 'rd', _ => 'th' }
      : switch (n) { 1 => 'er', _ => 'ème' };

  // ---- Info screen section titles ----

  String get infoTitle => isEn ? 'Information' : 'Informations';
  String get combinationValues =>
      isEn ? 'Combination values' : 'Valeur des combinaisons';
  String get mahjongBonusesSection =>
      isEn ? 'Mah-Jong Bonuses' : 'Bonus Mah-Jong';
  String get multipliersSection => isEn ? 'Multipliers' : 'Multiplicateurs';
  String get specialExplanations =>
      isEn ? 'Special explanations' : 'Explications spéciales';
  String get pointsDistribution =>
      isEn ? 'Points distribution' : 'Distribution des points';
  String get grandJeuxSection => 'Grand Jeux';
  String get languageSection => 'Langue / Language';
  String get creatorSection => isEn ? 'Creator' : 'Créateur';

  // ---- Info screen: combination table ----

  String get colCombination => isEn ? 'Combination' : 'Combinaison';
  String get colExposed => isEn ? 'Exposed' : 'Exposée';
  String get colHidden => isEn ? 'Hidden' : 'Cachée';

  List<List<String>> get combinationRows => isEn
      ? [
          ["Player's Wind Pair", '2', '2'],
          ['Dominant Wind Pair', '2', '2'],
          ['Dragon Pair', '0', '2'],
          ['Chow', '0', '0'],
          ['Minor Pung (2–8)', '2', '4'],
          ['Major Pung (1 or 9)', '4', '8'],
          ['Wind or Dragon Pung', '4', '8'],
          ['Minor Kong (2–8)', '8', '16'],
          ['Major Kong (1 or 9)', '16', '32'],
          ['Wind or Dragon Kong', '16', '32'],
          ['Each Flower', '4', '—'],
          ['Each Season', '4', '—'],
        ]
      : [
          ['Paire du Vent du joueur', '2', '2'],
          ['Paire du Vent dominant', '2', '2'],
          ['Paire de Dragons', '0', '2'],
          ['Suite', '0', '0'],
          ['Brelan ordinaire mineur (2–8)', '2', '4'],
          ['Brelan ordinaire majeur (1 ou 9)', '4', '8'],
          ['Brelan de Vents ou de Dragons', '4', '8'],
          ['Carré ordinaire mineur (2–8)', '8', '16'],
          ['Carré ordinaire majeur (1 ou 9)', '16', '32'],
          ['Carré de Vents ou de Dragons', '16', '32'],
          ['Chaque Fleur', '4', '—'],
          ['Chaque Saison', '4', '—'],
        ];

  // ---- Info screen: Mah-Jong bonuses list ----

  List<String> get mahjongBonusesList => isEn
      ? [
          'Mah-Jong: +20 pts',
          '4 Chows + 1 Pair: +10 pts',
          '4 Pungs/Kongs + 1 Pair: +10 pts',
          'Hand worth nothing: +10 pts',
          'Mah-Jong on an exposed tile: +10 pts',
          'Mah-Jong on a wall tile: +2 pts',
        ]
      : [
          'Faire Mah-Jong : +20 pts',
          '4 Suites + 1 Paire : +10 pts',
          '4 Brelans/Carrés + 1 Paire : +10 pts',
          'Main ne vaut rien : +10 pts',
          'Mah-Jong par une Tuile exposée : +10 pts',
          'Mah-Jong avec une Tuile du Mur : +2 pts',
        ];

  // ---- Info screen: multipliers list ----

  List<String> get multipliersList => isEn
      ? [
          'No Chows: ×2',
          'Moon from the deep sea: ×2',
          'Steal an exposed Kong: ×2',
          'Calling hand (winner only): ×2',
          'Fully concealed hand: ×2',
          'Winds and Dragons only: ×2',
          'Pure hand (one suit, no honours): ×8',
          'Mah-Jong on first deal: ×8',
          '— Player\'s Wind Pung or Kong: ×2',
          '— Dominant Wind Pung or Kong: ×2',
          '— Dragon Pung or Kong: ×2',
          '— Honours + one suit only: ×2',
          '— Player\'s own Flower or Season: ×2',
          '— Player\'s own Flower AND Season: ×4',
          '— All 4 Flowers or all 4 Seasons: ×16',
        ]
      : [
          'Main sans aucune Suite : ×2',
          'Pêcher la lune au fond de la mer : ×2',
          'Voler un Kong exposé : ×2',
          'Main appelante (gagnant seulement) : ×2',
          'Main entièrement cachée : ×2',
          'Main de Vents et de Dragons uniquement : ×2',
          'Main pure (une seule couleur, sans honneurs) : ×8',
          'Mah-Jong sur première donne : ×8',
          '— Brelan ou Carré du Vent du joueur : ×2',
          '— Brelan ou Carré du Vent dominant : ×2',
          '— Brelan ou Carré de Dragons : ×2',
          '— Main d\'Honneurs + une seule série : ×2',
          '— La Fleur ou la Saison du joueur : ×2',
          '— La Fleur ET la Saison du joueur : ×4',
          '— Les 4 Fleurs ou les 4 Saisons : ×16',
        ];

  // ---- Info screen: special explanation cards ----

  String get vocabTitle => isEn ? 'Vocabulary' : 'Vocabulaire';
  String get vocabBody => isEn
      ? 'Chow = run; Pung = triplet; Kong = quad.\n'
          'Dead wall = forbidden city.\n'
          'Tiles 2–8 = minor tiles; Tiles 1 & 9 = major/terminal tiles.\n'
          'Winds = simple honours; Dragons = superior honours; Flowers & Seasons = supreme honours / bonus tiles.'
      : 'Chow = suite; Pung = brelan; Kong = carré.\n'
          'Cité interdite = mur mort.\n'
          'Tuiles 2-8 = tuiles ordinaires/mineures; Tuiles 1 et 9 = tuiles majeures/extrêmités.\n'
          'Vents = honneurs simples; Dragons = honneurs supérieurs; Fleurs et Saisons = honneurs suprêmes/bonus.';

  String get assocTitle => isEn ? 'Associations' : 'Associations';
  String get assocBody => isEn
      ? 'Flower/Season 1 (Plum/Spring) = East.\n'
          'Flower/Season 2 (Orchid/Summer) = South.\n'
          'Flower/Season 3 (Chrysanthemum/Autumn) = West.\n'
          'Flower/Season 4 (Bamboo/Winter) = North.'
      : 'Fleur/Saison 1 (Prunier/Printemps) = Est.\n'
          'Fleur/Saison 2 (Orchidée/Été) = Sud.\n'
          'Fleur/Saison 3 (Chrysanthème/Automne) = Ouest.\n'
          'Fleur/Saison 4 (Bambou/Hiver) = Nord.';

  String get capTitle => isEn ? 'Score cap' : 'Limite de points';
  String get capBody => isEn
      ? 'An ordinary Mah-Jong hand score cannot exceed 1000 points. Only a Grand Jeu can score above 1000 points, and its score is not subject to any multiplier or bonus.'
      : 'Le score d\'un Mah-Jong ordinaire ne peut être supérieur à 1000 points. Seul un Grand Jeu permet de marquer plus de 1000 points, et le score de la combinaison n\'est sujet à aucun multiplicateur ou bonus.';

  String get callingHandTitle => isEn ? 'Calling hand' : 'Main appelante';
  String get callingHandBody => isEn
      ? 'A player declares their hand as "calling" (waiting for one tile).\n'
          '• If they then win: their score is doubled (×2).\n'
          '• If they do NOT win: only their flowers and seasons count; all other combinations are cancelled.'
      : 'Si un joueur n\'attend plus qu\'une seule tuile pour réaliser un Mah-Jong, il a la possibilité d\'annoncer « main appelante ».\n'
          '• S\'il fait ensuite Mah-Jong : ses points sont doublés (×2).\n'
          '• S\'il ne fait PAS Mah-Jong : seules ses fleurs et saisons comptent ; toutes ses autres combinaisons sont annulées.';

  String get moonTitle =>
      isEn ? 'Moon from the deep sea' : 'Pêcher la lune au fond de la mer';
  String get moonBody => isEn
      ? 'Win by drawing the last tile from the live wall (excluding the dead wall). Grants a ×2 multiplier.'
      : 'Faire Mah-Jong en tirant la dernière tuile du mur vivant (excluant le mur mort). Donne un multiplicateur ×2.';

  String get stealKongTitle =>
      isEn ? 'Steal an exposed Kong' : 'Voler un Kong exposé';
  String get stealKongBody => isEn
      ? 'Take the 4th tile added to an opponent\'s exposed Kong to win immediately. Grants a ×2 multiplier.'
      : 'Prendre la 4ème tuile ajoutée à un Kong exposé par un adversaire pour faire Mah-Jong immédiatement. Donne un multiplicateur ×2.';

  String get firstDealTitle => isEn ? 'First deal' : 'Sur première donne';
  String get firstDealBody => isEn
      ? 'Win on the very first deal. Grants ×8.'
      : 'Faire Mah-Jong dès la première donne. Donne ×8.';

  // ---- Info screen: distribution cards ----

  String get eastRuleTitle => isEn ? 'East Wind rule' : 'Règle du Vent d\'Est';
  String get eastRuleBody => isEn
      ? 'The East player wins double and loses double. Any payment involving East is multiplied by 2 (or ×4 for the difference between the winner and another player).'
      : 'Le joueur Est gagne double et perd double. Tout paiement impliquant Est est multiplié par 2 (ou ×4 pour les différences entre le gagnant et un autre joueur).';

  String get mahjongPaymentTitle =>
      isEn ? 'Mah-Jong payment' : 'Paiement Mah-Jong';
  String get mahjongPaymentBody => isEn
      ? 'If East wins: each opponent pays 2 × winner\'s score.\n'
          'If a non-East player wins: non-East opponents pay the winner\'s score; East pays 2 × winner\'s score.'
      : 'Si Est fait Mah-Jong : chaque adversaire paie 2 × score gagnant.\n'
          'Si non-Est fait Mah-Jong : les adversaires non-Est paient le score gagnant, Est paie 2 × score gagnant.';

  String get differentialTitle =>
      isEn ? 'Differential payments' : 'Paiements différentiels';
  String get differentialBody => isEn
      ? 'Between two losers: the lower-scoring pays the difference to the higher-scoring. ×2 if East is involved.\n'
          'Between winner and loser: if the loser has more points than the winner, the winner pays the difference ×2 (or ×4 if East is involved).'
      : 'Entre deux perdants : le moins fort paie la différence au plus fort. ×2 si Est est impliqué.\n'
          'Entre gagnant et perdant : si le perdant a plus de points que le gagnant, le gagnant paie la différence × 2 (ou × 4 si Est est impliqué).';

  // ---- Info screen: creator section ----

  String get vibecoded =>
      isEn ? 'Vibecoded with Claude Code' : 'Vibecoded avec Claude Code';
  String get followOnX => isEn ? 'Follow on X' : 'Suivre sur X';
  String get xLinkError =>
      isEn ? 'Unable to open the X link.' : 'Impossible d\'ouvrir le lien X.';
  String get followOnGitHub => isEn ? 'Follow on GitHub' : 'Suivre sur GitHub';
  String get gitHubLinkError => isEn
      ? 'Unable to open the GitHub link.'
      : 'Impossible d\'ouvrir le lien GitHub.';
}
