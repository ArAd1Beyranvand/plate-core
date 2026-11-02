import 'package:algeria_plate/algeria_plate.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plate_core/plate_core.dart';

void main() {
  test('the wilaya code names the wilaya', () {
    expect(AlgeriaRegions.lookup('09'), 'Blida');
    expect(AlgeriaRegions.lookup('16'), 'Algiers');
    expect(AlgeriaRegions.lookup('43'), 'Mila');
    expect(AlgeriaRegions.lookup('58'), 'El Menia');
  });

  test('nothing until the code is whole, issued and known', () {
    expect(AlgeriaRegions.lookup(''), isNull);
    expect(AlgeriaRegions.lookup('0'), isNull);
    expect(AlgeriaRegions.lookup('00'), isNull);
    expect(AlgeriaRegions.lookup('59'), isNull);
  });

  test('the controller follows each digit typed and deleted', () {
    final PlateController c = PlateController(spec: AlgeriaPlates.singleLine);
    c.setGroup('serial', '02639');
    c.setGroup('type', '126');
    expect(c.regionCaption, isNull);
    c.setGroup('wilaya', '0');
    expect(c.regionCaption, isNull);
    c.setGroup('wilaya', '09');
    expect(c.regionCaption, 'Blida');
    c.setGroup('wilaya', '0');
    expect(c.regionCaption, isNull);
  });
}
