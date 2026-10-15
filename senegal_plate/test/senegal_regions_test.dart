import 'package:flutter_test/flutter_test.dart';
import 'package:plate_core/plate_core.dart';
import 'package:senegal_plate/senegal_plate.dart';

void main() {
  test('a full region code names the region', () {
    expect(SenegalRegions.lookup('DK'), 'Dakar');
    expect(SenegalRegions.lookup('KE'), 'Kédougou');
    expect(SenegalRegions.lookup('ZG'), 'Ziguinchor');
  });

  test('a first letter names the region only when unambiguous', () {
    expect(SenegalRegions.lookup('F'), 'Fatick');
    expect(SenegalRegions.lookup('Z'), 'Ziguinchor');
    for (final String code in <String>['D', 'K', 'S', 'T', '']) {
      expect(SenegalRegions.lookup(code), isNull, reason: code);
    }
  });

  test('unissued codes name nothing', () {
    for (final String code in <String>['AA', 'DX', 'X']) {
      expect(SenegalRegions.lookup(code), isNull, reason: code);
    }
  });

  test('every plate follows each letter typed and deleted', () {
    for (final PlateSpec spec in SenegalPlates.all) {
      final PlateController c = PlateController(spec: spec);
      expect(c.regionCaption, isNull, reason: spec.id);
      c.setGroup('region', 'T');
      expect(c.regionCaption, isNull, reason: spec.id);
      c.setGroup('region', 'TH');
      expect(c.regionCaption, 'Thiès', reason: spec.id);
      c.setGroup('region', 'T');
      expect(c.regionCaption, isNull, reason: spec.id);
    }
  });
}
