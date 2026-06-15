import '../models/wind.dart';

// ---------------------------------------------------------------------------
// Input / Output
// ---------------------------------------------------------------------------

class PlayerScoreInput {
  final String gamePlayerId;
  final String playerName;
  final Wind currentWind;
  final int handScore;
  final bool isMahjong;

  const PlayerScoreInput({
    required this.gamePlayerId,
    required this.playerName,
    required this.currentWind,
    required this.handScore,
    required this.isMahjong,
  });
}

class DistributionResult {
  /// Net gain per gamePlayerId (positive = won, negative = lost).
  final Map<String, int> netGains;
  final List<String> log; // human-readable payment log (French)

  const DistributionResult({required this.netGains, required this.log});
}

// ---------------------------------------------------------------------------
// PointDistributor
// ---------------------------------------------------------------------------
//
// Rules implemented (verified against spec examples A–E):
//
// 1. Mahjong payment:
//    - If East wins → each opponent pays 2 × winnerScore.
//    - If non-East wins → non-East opponents pay winnerScore, East pays 2×.
//
// 2. Difference payments:
//    a. Between two non-winners:
//       diff = |scoreA – scoreB|; higher receives diff from lower.
//       If either is East: ×2.
//    b. Between winner and a loser:
//       If loser > winner: winner pays (loser – winner) × multiplier.
//         Neither East: ×2.  Either East: ×4.
//       If winner ≥ loser: no additional payment.
//
class PointDistributor {
  PointDistributor._();

  static DistributionResult distribute(List<PlayerScoreInput> players) {
    assert(players.length == 4, 'Exactly 4 players required');
    assert(players.where((p) => p.isMahjong).length == 1,
        'Exactly one Mahjong winner required');

    final gains = <String, int>{for (final p in players) p.gamePlayerId: 0};
    final log = <String>[];

    final winner = players.firstWhere((p) => p.isMahjong);
    final losers = players.where((p) => !p.isMahjong).toList();

    // ---- 1. Mahjong payments ----
    for (final loser in losers) {
      int payment = winner.handScore;
      final eastInvolved =
          winner.currentWind == Wind.est || loser.currentWind == Wind.est;
      if (eastInvolved) payment *= 2;

      gains[winner.gamePlayerId] = gains[winner.gamePlayerId]! + payment;
      gains[loser.gamePlayerId] = gains[loser.gamePlayerId]! - payment;

      log.add(
          '${loser.playerName} → ${winner.playerName} : $payment pts (Mah-Jong)');
    }

    // ---- 2. Difference payments ----
    for (var i = 0; i < players.length; i++) {
      for (var j = i + 1; j < players.length; j++) {
        final a = players[i];
        final b = players[j];

        if (a.isMahjong || b.isMahjong) {
          // Winner vs loser
          final w = a.isMahjong ? a : b;
          final l = a.isMahjong ? b : a;

          if (l.handScore > w.handScore) {
            final diff = l.handScore - w.handScore;
            final eastInvolved =
                w.currentWind == Wind.est || l.currentWind == Wind.est;
            final payment = diff * (eastInvolved ? 4 : 2);

            gains[w.gamePlayerId] = gains[w.gamePlayerId]! - payment;
            gains[l.gamePlayerId] = gains[l.gamePlayerId]! + payment;

            log.add(
                '${w.playerName} → ${l.playerName} : $payment pts (diff ${l.handScore} – ${w.handScore} × ${eastInvolved ? 4 : 2})');
          }
        } else {
          // Both non-winners
          if (a.handScore != b.handScore) {
            final higher = a.handScore > b.handScore ? a : b;
            final lower = a.handScore > b.handScore ? b : a;
            final diff = higher.handScore - lower.handScore;
            final eastInvolved =
                a.currentWind == Wind.est || b.currentWind == Wind.est;
            final payment = diff * (eastInvolved ? 2 : 1);

            gains[higher.gamePlayerId] = gains[higher.gamePlayerId]! + payment;
            gains[lower.gamePlayerId] = gains[lower.gamePlayerId]! - payment;

            log.add(
                '${lower.playerName} → ${higher.playerName} : $payment pts (diff ${higher.handScore} – ${lower.handScore}${eastInvolved ? " × 2 (Est)" : ""})');
          }
        }
      }
    }

    return DistributionResult(netGains: gains, log: log);
  }
}
