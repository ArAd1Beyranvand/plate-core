import 'package:flutter_test/flutter_test.dart';
import 'package:indonesia_plate/indonesia_plate.dart';
import 'package:plate_core/plate_core.dart';

void main() {
  test('a code names its province, with the area where there are several', () {
    expect(IndonesiaRegions.lookup('B'), 'Jakarta');
    expect(IndonesiaRegions.lookup('DK'), 'Bali');
    expect(IndonesiaRegions.lookup('BB'), 'North Sumatra (Western)');
  });

  test('an unissued prefix names nothing', () {
    for (final String code in <String>['', 'X', 'QQ']) {
      expect(IndonesiaRegions.lookup(code), isNull, reason: code);
    }
  });

  test('every serial layout follows the prefix typed and deleted', () {
    for (final PlateSpec spec in <PlateSpec>[
      IndonesiaPlates.car,
      IndonesiaPlates.carEv,
      IndonesiaPlates.motorcycle,
      IndonesiaPlates.motorcycleEv,
    ]) {
      final PlateController c = PlateController(spec: spec);
      expect(c.regionCaption, isNull, reason: spec.id);
      c.setGroup('prefix', 'D');
      expect(c.regionCaption, 'West Java (central Preanger Regencies)');
      c.setGroup('prefix', 'DK');
      expect(c.regionCaption, 'Bali', reason: spec.id);
      c.setGroup('prefix', '');
      expect(c.regionCaption, isNull, reason: spec.id);
    }
  });

  test('the diplomatic plate has no caption', () {
    final PlateController c = PlateController(spec: IndonesiaPlates.diplomatic);
    expect(c.regionCaption, isNull);
  });
}
