import 'package:flutter_test/flutter_test.dart';
import 'package:india_plate/india_plate.dart';
import 'package:plate_core/plate_core.dart';

void main() {
  test('current and former codes name the state', () {
    expect(IndiaRegions.lookup('MH'), 'Maharashtra');
    expect(IndiaRegions.lookup('TG'), 'Telangana');
    expect(IndiaRegions.lookup('TS'), 'Telangana');
    expect(IndiaRegions.lookup('OR'), 'Odisha');
  });

  test('a lone letter and unissued codes name nothing', () {
    for (final String code in <String>['', 'M', 'ZZ', 'BH']) {
      expect(IndiaRegions.lookup(code), isNull, reason: code);
    }
  });

  test('the caption follows the state typed and deleted', () {
    final PlateController c = PlateController(spec: IndiaPlates.private);
    expect(c.regionCaption, isNull);
    c.setGroup('state', 'M');
    expect(c.regionCaption, isNull);
    c.setGroup('state', 'KA');
    expect(c.regionCaption, 'Karnataka');
    c.setGroup('state', 'K');
    expect(c.regionCaption, isNull);
  });

  test('a plate without a state code has no caption', () {
    final PlateController c = PlateController(spec: IndiaPlates.bharat);
    expect(c.regionCaption, isNull);
  });
}
