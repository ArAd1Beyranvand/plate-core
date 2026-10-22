import 'package:flutter_test/flutter_test.dart';
import 'package:niger_plate/niger_plate.dart';
import 'package:plate_core/plate_core.dart';

void main() {
  test('the leading digit names the region', () {
    expect(NigerRegions.lookup('1'), 'Agadez');
    expect(NigerRegions.lookup('8'), 'Niamey');
  });

  test('empty and unissued digits name nothing', () {
    for (final String code in <String>['', '0', '9']) {
      expect(NigerRegions.lookup(code), isNull, reason: code);
    }
  });

  test('both plates follow the digit typed and deleted', () {
    for (final PlateSpec spec in <PlateSpec>[NigerPlates.privateSpec, NigerPlates.commercialSpec]) {
      final PlateController c = PlateController(spec: spec);
      expect(c.regionCaption, isNull, reason: spec.id);
      c.setGroup('region', '6');
      expect(c.regionCaption, 'Tillabéri', reason: spec.id);
      c.setGroup('region', '');
      expect(c.regionCaption, isNull, reason: spec.id);
    }
  });
}
