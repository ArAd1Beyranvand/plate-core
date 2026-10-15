import 'package:bolivia_plate/bolivia_plate.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plate_core/plate_core.dart';

void main() {
  test('a department letter names the department', () {
    expect(BoliviaRegions.lookup('L'), 'La Paz');
    expect(BoliviaRegions.lookup('H'), 'Chuquisaca');
    expect(BoliviaRegions.lookup('S'), 'Santa Cruz');
  });

  test('empty and unissued letters name nothing', () {
    for (final String code in <String>['', 'A', 'Z', 'LP']) {
      expect(BoliviaRegions.lookup(code), isNull, reason: code);
    }
  });

  test('the PTA plate follows the department letter; others have none', () {
    final PlateController c = PlateController(spec: BoliviaPlates.standard());
    expect(c.regionCaption, isNull);
    c.setGroup('department', 'T');
    expect(c.regionCaption, 'Tarija');
    c.setGroup('department', '');
    expect(c.regionCaption, isNull);
    expect(BoliviaPlates.special().resolveRegion, isNull);
    expect(BoliviaPlates.mercosur.resolveRegion, isNull);
  });
}
