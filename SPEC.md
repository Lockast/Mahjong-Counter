You are Claude Code running inside VS Code on Ubuntu. Build me a complete Android app for tracking real-life Mah-Jong game scores. The app must be designed so it can be moved to iOS later, so use Flutter + Dart, not native Android/Kotlin. Create all files needed for a working Flutter project, including tests, documentation, asset setup, and instructions to compile/test on a OnePlus 15 or Samsung S20.

The app language/UI must be French.

High-level app goal:
I play Mah-Jong in real life with 4 players. I want an app to create a game, input each player’s hand/score each turn, calculate scores, distribute points automatically, store game history, and generate player statistics.

Use these technologies unless there is a strong reason not to:
- Flutter stable
- Dart
- Local persistence with SQLite, preferably drift, or a well-structured local database solution
- Riverpod or another clean state management approach
- Material 3 UI
- Unit tests for score calculation and point distribution
- No backend server

App sections:
The app has a bottom navigation bar with 4 sections:
1. Jouer
2. Historique
3. Joueurs
4. Info

SECTION 1: JOUER

Bottom-left button:
- Label: “Jouer”
- Icon/symbol: “+”

New game flow:
When clicking “Jouer”, show a screen to create a new game.
The screen must display 4 text fields/placeholders to input player names.
Each text field corresponds to a wind:
- 東 with “Est” under it
- 南 with “Sud” under it
- 西 with “Ouest” under it
- 北 with “Nord” under it

The initial seating/wind assignment is:
- Player 1 = Est
- Player 2 = Sud
- Player 3 = Ouest
- Player 4 = Nord

After entering 4 names, the user presses:
- “Commencer”

Game score screen:
After pressing “Commencer”, show a score screen with the following features:
- Four player columns at the top
- Player names at the top
- Big current total score under each name
- Below that, rows for each turn showing each player’s gain/loss for that turn
- Positive numbers should be in gree and negative numbers in red
- A centered floating “+” button near the bottom to add a new turn

Wind rotation:
At game creation the players choose/receive their starting wind by name placement.
After every turn, the players’ winds rotate:
- Est becomes Nord
- Sud becomes Est
- Ouest becomes Sud
- Nord becomes Ouest

So for each new turn the app must know each player’s current personal wind.

Adding a new turn:
When the user taps the “+” button:
1. Show a turn input screen/bottom sheet.
2. The user chooses:
   - Which player’s hand to enter
   - The current dominant wind for the turn
3. For each player, the app lets the user input the hand/score.
4. When a player’s hand has been entered and calculated, show the calculated points next to that player’s name in the player selection list.
5. When all four players have a hand score, allow the user to validate the turn.
6. After validating the turn, automatically distribute the points between players and add the result row to the game score screen.
7. A swipe down or back action should return to the score screen.

Conflict handling:
- It is impossible for two players to have Mahjong in the same turn.
- If one player selected a Grand Jeu, that player counts as the Mahjong winner for that turn.
- Exactly one player should normally be marked as Mahjong/Grand Jeu before validating a turn.
- Show clear French error messages for conflicts:
  - “Un seul joueur peut faire Mah-Jong.”
  - “Veuillez saisir les scores des 4 joueurs.”
  - “Veuillez choisir le joueur qui a fait Mah-Jong.”
  - etc.

Hand input UI:
For the selected player, show buttons/toggles.

Main buttons:
- “Mah-Jong”
  - highlighted when selected
- “Grand Jeu”
  - when selected, display the list of possible special combinations
  - user selects one Grand Jeu
  - selected Grand Jeu name replaces the button text and the button stays highlighted
  - if Grand Jeu is selected, do not require tile input; the player’s points are the fixed Grand Jeu value

Additional buttons shown for a Mahjong hand, the selected one will apply bonus points or multiplier to the player score:
- “Tuile exposée”
- “Tuile mur”
- “Pêcher la lune au fond de la mer”
- “Vol kong exposé”
- “Main appelante”
- “Sur première donne”

Tile input:
- I already have JPG images for the Mahjong tiles.
- Use JPG assets from `assets/tiles/`.
- Create a clear tile asset mapping file, for example `assets/tile_catalog.json`, so I can adapt filenames if needed.
- Display available Mahjong tiles as clickable images.
- The user selects tiles by tapping images.
- The same tile can be selected several times.
- Above the tile grid, display selected tiles in order so the user can track what has already been input.
- Add an undo/remove-last button.
- Add a clear/reset button.
- Add a toggle:
  - “Exposé”
  - “Caché”
- Each selected tile must remember whether it was selected as exposed or hidden.
- When the user taps “OK”, calculate the player’s hand score.

Hand score calculation:
Implement a scoring engine in pure Dart with unit tests.

Use this table for ordinary hand values:

Valeur de chaque main:
Combinaisons:
- Paire du Vent du joueur: 2 points exposée, 2 points cachée
- Paire du Vent dominant: 2 points exposée, 2 points cachée
- Paire de Dragons: 0 points exposée, 2 points cachée
- Suite: 0 points exposée, 0 points cachée
- Brelan de Tuiles ordinaires mineures n°2 à 8: 2 points exposée, 4 points cachée
- Brelan de Tuiles ordinaires majeures n°1 ou 9: 4 points exposée, 8 points cachée
- Brelan de Vents ou de Dragons: 4 points exposée, 8 points cachée
- Carré de Tuiles ordinaires mineures n°2 à 8: 8 points exposée, 16 points cachée
- Carré de Tuiles ordinaires majeures n°1 ou 9: 16 points exposée, 32 points cachée
- Carré de Vents ou de Dragons: 16 points exposée, 32 points cachée
- Chaque Fleur: 4 points
- Chaque Saison: 4 points

Valeur de la main qui fait Mah-Jong:
- Faire Mah-Jong: 20 points
- La Main est composée de 4 Suites et d’une Paire: 10 points
- La Main est composée de 4 Brelans ou Carrés et d’une Paire: 10 points
- La Main ne vaut rien: 10 points
- Faire Mah-Jong par une Tuile exposée: 10 points
- Mah-Jong avec une Tuile provenant du Mur: 2 points

Doubles/triples/multipliers:
- La Main ne comporte aucune Suite: x2
- “Pêcher la lune au fond de la mer”: x2
- Faire Mah-Jong “en volant un Kong exposé”: x2
- Faire Mah-Jong avec une “Main appelante”: x2
- La Main est entièrement cachée: x2
- La Main ne comporte que des Vents et des Dragons: x2
- La Main est “pure”, all tiles from the same family/suit: x8
- Faire Mah-Jong sur première donne: x8

Additional doubles:
- Brelan ou Carré du Vent du joueur: x2
- Brelan ou Carré du Vent dominant: x2
- Brelan ou Carré de Dragons: x2
- Main composée d’Honneurs et d’une seule série: x2
- La Fleur ou la Saison du joueur: x2
- La Fleur et la Saison du joueur: x4
- Les 4 Fleurs and/or les 4 Saisons: x16

Special notes:
- Ordinary Mahjong score limit: an ordinary Mah-Jong cannot score more than 1000 points.
- Only a Grand Jeu can score more than 1000 points.
- A Grand Jeu score is fixed and is not affected by bonuses or multipliers.
- “Voler un Kong exposé” means taking the 4th tile of a Kong that has just been exposed in order to make Mah-Jong.
- “Pêcher la lune au fond de la mer” means doing Mah-Jong by drawing the last tile of the wall, excluding the untouched dead wall.
- “Main appelante”: if a player has announced “main appelante” and then makes Mah-Jong, his points are doubled. If an opponent makes Mah-Jong instead, that player only scores flowers and seasons; other combinations are cancelled. Implement the data model to support this. If the UI flow is too complex, at minimum implement it for the Mahjong winner and leave a clearly documented TODO for non-winning callers.

Grand Jeux:
Implement these fixed scores in the app and show them in the “Grand Jeu” selector and the Info section:
- La Main des paires: 500 points
- Les 7 Lanternes du Palais: 500 points
- Les Chow Venteux: 500 points
- Le Chow Royal: 600 points
- La Main Chinoise: 700 points
- Le Joueur Maladroit: 700 points
- La Main Pleine de 9 pièces: 700 points
- Les Pung Venteux: 800 points
- Le Petit Serpent: 1000 points
- Les Paires Venteuses: 1000 points
- Le Jardin de Gretos: 1100 points
- Les Grands Frères: 1200 points
- La Main d’Opaline: 1300 points
- La Main de Jade: 1300 points
- La Main de Corail: 1300 points
- Les Paires de Shozum: 1300 points
- La Main de Diamant, grand serpent: 1400 points
- La Main d’Émeraude, grand serpent: 1400 points
- La Main de Rubis, grand serpent: 1400 points
- Le Serpentin des 4 Vents: 1400 points
- Le Triangle Venteux: 1400 points
- Le Serpentin Royal: 1500 points
- Les 13 Lanternes Merveilleuses: 1600 points
- Les 7 Muses du Poète Chinois: 1700 points
- Le Pung Royal: 1800 points
- Les 4 Bonheurs Domestiques: 2000 points
- Les 3 Grands Apôtres: 2000 points
- Les 3 Fils Adoptifs du Dragon: 2200 points
- Le Triangle Éternel, ou Le Ying et le Yang: 2500 points
- Les Ennemis: 2500 points
- La Tempête: 3000 points
- La Grande Main Verte: 3500 points
- Le Souffle du Dragon: 4000 points
- Le Mahjong Impérial: 5000 points

Point distribution rules:
Implement this as a separate pure Dart service with unit tests.

Definitions:
- Each player first has a hand score.
- One player is the Mahjong winner.
- East wind, “Vent d’Est”, always wins double and loses double.
- If a payment involves East, the payment is doubled unless a stronger special rule says x4.

Algorithm:
1. Mahjong payment:
   - The Mahjong winner is paid by each opponent.
   - If East makes Mahjong, every opponent pays East 2 × winnerScore.
   - If a non-East player makes Mahjong, normal opponents pay winnerScore, but East pays 2 × winnerScore.

2. Difference payments after Mahjong:
   Compare points between players.
   Use these rules:
   - Between two non-winning ordinary players:
     - lower hand score pays higher hand score the difference.
     - if East is involved, double the difference.
   - Between the Mahjong winner and another player:
     - If the winner’s hand score is greater than or equal to the other player’s score, there is no difference payment between them, because the Mahjong payment already happened.
     - If the other player has more points than the Mahjong winner, the Mahjong winner must pay that player.
       - If neither side is East: pay 2 × difference.
       - If East is involved: pay 4 × difference.
   - This special rule also applies when East is the Mahjong winner but another player has more hand points than East.

Examples to test:
Example A:
East wins Mahjong with 100.
South, West, North each pay East 200.
East receives +600 total before difference payments.

Example B:
East wins Mahjong with 100.
South has 250, West 40, North 10.
First: everyone pays East 200.
Then South exceeds East by 150, so East pays South 150 × 4 = 600.
Difference payments:
North pays West 30.
North pays South 240.
West pays South 210.

Example C:
South wins Mahjong with 100.
East has 30, West has 50, North has 10.
Mahjong payment:
East pays South 200.
West pays South 100.
North pays South 100.
Difference payments:
North pays West 40.
North pays East 40 because East has 30 vs North 10, difference 20 doubled.
East pays West 40 because West has 50 vs East 30, difference 20 doubled.

Example D:
South wins Mahjong with 100.
West has 160.
West pays South 100 for Mahjong.
Then South pays West 2 × 60 = 120.

Example E:
South wins Mahjong with 100.
East has 160.
East pays South 200 for Mahjong.
Then South pays East 4 × 60 = 240.

Data storage:
Persist:
- Players
- Games
- Turns
- Player hand scores per turn
- Gain/loss per player per turn
- Winner per turn
- Dominant wind per turn
- Player wind per turn
- Grand Jeu achieved, if any
- Special flags selected
- Tile selections, if feasible
- Date/time of game

SECTION 2: HISTORIQUE

Show list of completed and in-progress games.
For each game show:
- Date
- Players
- Final scores
- Winner
- Number of turns

When opening a game:
- Show score evolution by turn
- Show each turn’s hand scores
- Show gain/loss distribution
- Show who did Mahjong
- Show dominant wind
- Show Grand Jeu if applicable
- Allow continuing an unfinished game if not completed

SECTION 3: JOUEURS

Show all players who have played at least one game.
For each player show statistics:
- Number of games played
- Percentage of 1st place
- Percentage of 2nd place
- Percentage of 3rd place
- Percentage of 4th place
- Mean final game score
- Median final game score
- List of Grand Jeux/special combinations achieved and count
- Favorite kind of combination, if detectable
- Favorite season, flower, and tile family, if detectable from saved tile data

If some favorite statistics cannot be computed because the tile data is missing, show:
“Pas encore assez de données.”

SECTION 4: INFO

Show rules/reference information:
- Ordinary hand values
- Mahjong bonuses
- Multipliers
- Explanation of “Main appelante”
- Explanation of “Pêcher la lune au fond de la mer”
- Explanation of “Voler un Kong exposé”
- Grand Jeux list with points
- A clear explanation of point distribution, especially East double win/loss rule

Architecture requirements:
- Keep scoring logic independent of UI.
- Put scoring classes/services in something like `lib/core/scoring/`.
- Use models/entities with clear names.
- Use immutable models where practical.
- Add unit tests for:
  - ordinary hand score calculation
  - Grand Jeu fixed scoring
  - ordinary Mahjong score cap of 1000
  - the point distribution examples above
  - wind rotation
  - conflict validation: impossible to have two Mahjong winners

UI requirements:
- French text everywhere.
- Clean Material 3 design.
- Bottom navigation.
- Score screen visually similar to the screenshot:
  - player names as colored headers
  - big total score under each player
  - turn rows below
  - centered floating + button
- Must work well on Android phones such as Samsung S20 and OnePlus 15.
- Responsive layout for different screen sizes.
- Avoid tiny text.
- Provide dark/light mode compatibility if simple.

Assets:
- Use `assets/tiles/` for tile JPGs.
- Create a documented asset naming convention.
- Create or expect `assets/tile_catalog.json`.
- If tile images are missing, use placeholder widgets but keep the app working.
- Add instructions in README explaining where I should put my PNG tiles and how to update the mapping.

Deliverables:
1. Complete Flutter project files.
2. Clean folder structure.
3. README.md with:
   - prerequisites on Ubuntu
   - Flutter installation/check instructions
   - how to connect Android phone with USB debugging
   - how to run on OnePlus/Samsung:
     - `flutter doctor`
     - `flutter pub get`
     - `adb devices`
     - `flutter run`
   - how to build APK:
     - `flutter build apk --release`
   - where to put tile PNG assets
   - how to run tests:
     - `flutter test`
4. Unit tests.
5. Seed data for Grand Jeux and scoring values.
6. A short explanation of important implementation choices.

Important:
- Do not leave the project half-created.
- If you need to make an assumption, document it in README.md.
- Prioritize a working MVP with correct scoring/distribution over visual perfection.
- After creating files, run formatting/analyze/tests where possible:
  - `dart format .`
  - `flutter analyze`
  - `flutter test`
- Fix errors you find.