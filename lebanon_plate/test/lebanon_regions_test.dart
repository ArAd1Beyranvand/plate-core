import 'package:flutter_test/flutter_test.dart';
import 'package:lebanon_plate/lebanon_plate.dart';
import 'package:plate_core/plate_core.dart';

void main() {
  test('a town letter names the town', () {
    expect(LebanonRegions.lookup('B'), 'Beirut');
    expect(LebanonRegions.lookup('Z'), 'Zahleh, Beqaa');
    expect(LebanonRegions.lookup('T'), 'Tripoli, North Lebanon');
  });

  test('other letters name no town', () {
    for (final String code in <String>['', 'A', 'J', 'R', 'M', 'P', 'K']) {
      expect(LebanonRegions.lookup(code), isNull, reason: code);
    }
  });

  test('both plates follow the letter typed and deleted', () {
    for (final PlateSpec spec in LebanonPlates.all) {
      final PlateController c = PlateController(spec: spec);
      expect(c.regionCaption, isNull, reason: spec.id);
      c.setGroup('letter', 'S');
      expect(c.regionCaption, 'Sidon, South Lebanon', reason: spec.id);
      c.setGroup('letter', '');
      expect(c.regionCaption, isNull, reason: spec.id);
    }
  });
}
