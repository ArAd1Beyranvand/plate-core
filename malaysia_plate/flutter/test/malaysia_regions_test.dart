import 'package:flutter_test/flutter_test.dart';
import 'package:malaysia_plate/malaysia_plate.dart';
import 'package:plate_core/plate_core.dart';

void main() {
  test('the longest known code names the place', () {
    expect(MalaysiaRegions.lookup('VRX'), 'Kuala Lumpur');
    expect(MalaysiaRegions.lookup('K'), 'Kedah');
    expect(MalaysiaRegions.lookup('KV'), 'Langkawi');
    expect(MalaysiaRegions.lookup('QSG'), 'Sarawak Government');
    expect(MalaysiaRegions.lookup('QS'), 'Sibu / Mukah');
    expect(MalaysiaRegions.lookup('SMA'), 'Sandakan');
  });

  test('an empty, split or unknown prefix names nothing', () {
    for (final String code in <String>['', 'Q', 'S', 'SG', 'QX', 'Z']) {
      expect(MalaysiaRegions.lookup(code), isNull, reason: code);
    }
  });

  test('every layout follows the prefix typed and deleted', () {
    for (final PlateSpec spec in <PlateSpec>[
      MalaysiaPlates.singleRow(),
      MalaysiaPlates.twoRow(suffix: true),
      MalaysiaPlates.ev(),
    ]) {
      final PlateController c = PlateController(spec: spec);
      expect(c.regionCaption, isNull, reason: spec.id);
      c.setGroup('prefix', 'W');
      expect(c.regionCaption, 'Kuala Lumpur', reason: spec.id);
      c.setGroup('prefix', 'Q');
      expect(c.regionCaption, isNull, reason: spec.id);
      c.setGroup('prefix', '');
      expect(c.regionCaption, isNull, reason: spec.id);
    }
  });
}
