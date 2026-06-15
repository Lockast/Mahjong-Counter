import 'package:flutter_test/flutter_test.dart';
import 'package:mahjong_tracker/core/models/wind.dart';
import 'package:mahjong_tracker/core/scoring/point_distributor.dart';

PlayerScoreInput p(
  String id,
  String name,
  Wind wind,
  int score, {
  bool mahjong = false,
}) =>
    PlayerScoreInput(
      gamePlayerId: id,
      playerName: name,
      currentWind: wind,
      handScore: score,
      isMahjong: mahjong,
    );

void main() {
  // Helper: sum of all net gains must be 0 (zero-sum).
  void expectZeroSum(DistributionResult r) {
    final total = r.netGains.values.fold(0, (a, b) => a + b);
    expect(total, 0, reason: 'Net gains must sum to zero');
  }

  // ---------------------------------------------------------------------------
  // Example A: East wins Mahjong with 100, others have 0
  // ---------------------------------------------------------------------------
  test('Example A — East wins 100, others 0', () {
    final result = PointDistributor.distribute([
      p('E', 'Est', Wind.est, 100, mahjong: true),
      p('S', 'Sud', Wind.sud, 0),
      p('W', 'Ouest', Wind.ouest, 0),
      p('N', 'Nord', Wind.nord, 0),
    ]);

    expectZeroSum(result);
    expect(result.netGains['E'], 600); // 3 × 200
    expect(result.netGains['S'], -200);
    expect(result.netGains['W'], -200);
    expect(result.netGains['N'], -200);
  });

  // ---------------------------------------------------------------------------
  // Example B: East wins 100, South 250, West 40, North 10
  // ---------------------------------------------------------------------------
  test('Example B — East wins, South > East', () {
    final result = PointDistributor.distribute([
      p('E', 'Est', Wind.est, 100, mahjong: true),
      p('S', 'Sud', Wind.sud, 250),
      p('W', 'Ouest', Wind.ouest, 40),
      p('N', 'Nord', Wind.nord, 10),
    ]);

    expectZeroSum(result);
    // Mahjong: each pays 200 → East +600
    // South > East 150 × 4 = 600 → East -600, South +600
    // North pays West 30, North pays South 240, West pays South 210
    expect(result.netGains['E'], 0);
    expect(result.netGains['S'], 850);
    expect(result.netGains['W'], -380);
    expect(result.netGains['N'], -470);
  });

  // ---------------------------------------------------------------------------
  // Example C: South wins 100, East 30, West 50, North 10
  // ---------------------------------------------------------------------------
  test('Example C — South wins, differences with East', () {
    final result = PointDistributor.distribute([
      p('E', 'Est', Wind.est, 30),
      p('S', 'Sud', Wind.sud, 100, mahjong: true),
      p('W', 'Ouest', Wind.ouest, 50),
      p('N', 'Nord', Wind.nord, 10),
    ]);

    expectZeroSum(result);
    expect(result.netGains['E'],
        -200); // pays 200 for Mahjong, +40 diff, -40 diff = net -200
    expect(result.netGains['S'], 400);
    expect(result.netGains['W'], -20);
    expect(result.netGains['N'], -180);
  });

  // ---------------------------------------------------------------------------
  // Example D: South wins 100, West 160
  // ---------------------------------------------------------------------------
  test('Example D — South wins, West > South', () {
    final result = PointDistributor.distribute([
      p('E', 'Est', Wind.est, 0),
      p('S', 'Sud', Wind.sud, 100, mahjong: true),
      p('W', 'Ouest', Wind.ouest, 160),
      p('N', 'Nord', Wind.nord, 0),
    ]);

    expectZeroSum(result);
    // West pays South 100 (Mahjong). South pays West 2×60=120.
    // But South also receives 200 (East) + 100 (North) from Mahjong payments.
    // East also pays West 320 (non-winner diff, East involved).
    // South total: +400(Mahjong) - 120(diff to West) = +280.
    expect(result.netGains['S'], 280);
    expect(result.netGains['W'],
        500); // -100(MJ) +120(from S) +320(from E) +160(from N)
    expect(result.netGains['E'], -520); // -200(MJ) -320(diff to W)
    expect(result.netGains['N'], -260); // -100(MJ) -160(diff to W)
  });

  // ---------------------------------------------------------------------------
  // Example E: South wins 100, East 160
  // ---------------------------------------------------------------------------
  test('Example E — South wins, East > South', () {
    final result = PointDistributor.distribute([
      p('E', 'Est', Wind.est, 160),
      p('S', 'Sud', Wind.sud, 100, mahjong: true),
      p('W', 'Ouest', Wind.ouest, 0),
      p('N', 'Nord', Wind.nord, 0),
    ]);

    expectZeroSum(result);
    // East pays South 200 (Mahjong with East). South pays East 4×60=240.
    final eastGain = result.netGains['E']!;
    final southGain = result.netGains['S']!;
    // East net: -200 (Mahjong) + 240 (diff from South) + 320 (from West) + 320 (from North) = +680
    expect(eastGain, 680);
    // South: +200 (Mahjong) - 240 (diff to East) = net positive (160)
    expect(southGain, 160);
  });

  // ---------------------------------------------------------------------------
  // Conflict: exactly one Mahjong player required
  // ---------------------------------------------------------------------------
  test('throws on zero Mahjong winners', () {
    expect(
      () => PointDistributor.distribute([
        p('E', 'Est', Wind.est, 100),
        p('S', 'Sud', Wind.sud, 100),
        p('W', 'Ouest', Wind.ouest, 100),
        p('N', 'Nord', Wind.nord, 100),
      ]),
      throwsA(isA<AssertionError>()),
    );
  });

  test('throws on two Mahjong winners', () {
    expect(
      () => PointDistributor.distribute([
        p('E', 'Est', Wind.est, 100, mahjong: true),
        p('S', 'Sud', Wind.sud, 100, mahjong: true),
        p('W', 'Ouest', Wind.ouest, 100),
        p('N', 'Nord', Wind.nord, 100),
      ]),
      throwsA(isA<AssertionError>()),
    );
  });
}
