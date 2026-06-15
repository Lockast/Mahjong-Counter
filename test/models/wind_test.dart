import 'package:flutter_test/flutter_test.dart';
import 'package:mahjong_tracker/core/models/wind.dart';

void main() {
  group('Wind', () {
    test('labels', () {
      expect(Wind.est.label, 'Est');
      expect(Wind.sud.label, 'Sud');
      expect(Wind.ouest.label, 'Ouest');
      expect(Wind.nord.label, 'Nord');
    });

    test('symbols', () {
      expect(Wind.est.symbol, '東');
      expect(Wind.sud.symbol, '南');
      expect(Wind.ouest.symbol, '西');
      expect(Wind.nord.symbol, '北');
    });

    test('numbers 1–4', () {
      expect(Wind.est.number, 1);
      expect(Wind.sud.number, 2);
      expect(Wind.ouest.number, 3);
      expect(Wind.nord.number, 4);
    });

    test('fromNumber round-trip', () {
      for (var i = 1; i <= 4; i++) {
        expect(Wind.fromNumber(i).number, i);
      }
    });

    test('rotation: Est→Nord, Sud→Est, Ouest→Sud, Nord→Ouest', () {
      expect(Wind.est.next, Wind.nord);
      expect(Wind.sud.next, Wind.est);
      expect(Wind.ouest.next, Wind.sud);
      expect(Wind.nord.next, Wind.ouest);
    });

    test('rotation is cyclic after 4 steps', () {
      Wind w = Wind.est;
      for (var i = 0; i < 4; i++) w = w.next;
      expect(w, Wind.est);
    });

    test('GamePlayer.windAtTurn matches spec', () {
      // Player 1 starts Est.
      // Turn 0 → Est, Turn 1 → Nord, Turn 2 → Ouest, Turn 3 → Sud
      final expected = [Wind.est, Wind.nord, Wind.ouest, Wind.sud];
      for (var i = 0; i < 4; i++) {
        var current = Wind.est;
        for (var j = 0; j < i; j++) current = current.next;
        expect(current, expected[i],
            reason: 'Turn $i should be ${expected[i].label}');
      }
    });

    test('fromString', () {
      expect(Wind.fromString('est'), Wind.est);
      expect(Wind.fromString('sud'), Wind.sud);
      expect(Wind.fromString('ouest'), Wind.ouest);
      expect(Wind.fromString('nord'), Wind.nord);
      expect(Wind.fromString('invalid'), null);
    });
  });
}
