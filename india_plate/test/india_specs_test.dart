import 'package:plate_core/plate_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:india_plate/india_plate.dart';

void main() {
  PlateValidation judge(PlateSpec spec, String value) =>
      const IndiaValidator().validate(PlateEntry(spec: spec, values: value.split(' ')));

  test('every spec passes debugValidateSpec', () {
    for (final spec in IndiaPlates.all) {
      expect(debugValidateSpec(spec), isTrue);
    }
  });

  test('fixed characters render into the text, not the slots', () {
    final spec = IndiaPlates.bharat;
    expect(spec.slotCount, 3);
    final values = <String?>['21', '2345', 'AA'];
    expect(
      spec.effectiveTextGroups.map((g) => spec.renderGroup(g, values)).join(' '),
      '21 BH2345 AA',
    );
  });

  test('validator', () {
    expect(judge(IndiaPlates.private, 'MH 20 DV 2366').isValid, isTrue);
    expect(judge(IndiaPlates.private, 'XX 20 DV 2366').isValid, isFalse);
    expect(judge(IndiaPlates.private, 'MH 00 DV 2366').isValid, isFalse);
    expect(judge(IndiaPlates.private, 'MH 20 DV 0000').isValid, isFalse);
    expect(judge(IndiaPlates.private, 'XX 20').isValid, isTrue, reason: 'quiet until full');
    expect(judge(IndiaPlates.temporary, '1323 KL 5986 KA').isValid, isFalse);
    expect(judge(IndiaPlates.temporary, '1123 KL 5986 KA').isValid, isTrue);
    expect(judge(IndiaPlates.military, '02 B 084821 H').isValid, isTrue);
    expect(judge(IndiaPlates.military, '02 I 084821 H').isValid, isFalse);
    expect(judge(IndiaPlates.diplomatic, '052 CD 19').isValid, isTrue);
    expect(judge(IndiaPlates.diplomatic, '052 XX 19').isValid, isFalse);
    expect(
      judge(IndiaPlates.diplomatic, '5 CD 1').isValid,
      isTrue,
      reason: 'mission and number start at one digit',
    );
    expect(IndiaPlates.diplomatic.slots.first.minLength, 1);
    expect(judge(IndiaPlates.trade, 'UP 16 K 0002 0073').isValid, isFalse);
  });
}
