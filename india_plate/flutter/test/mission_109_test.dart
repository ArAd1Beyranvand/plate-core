import 'package:flutter_test/flutter_test.dart';
import 'package:india_plate/india_plate.dart';
import 'package:plate_core/plate_core.dart';

void main() {
  const notFound = 'COUNTRY NOT FOUND';
  final spec = IndiaPlates.diplomatic;

  test('spec refuses mission 109', () {
    expect(spec.restrictions, contains(IndiaMissions.restriction));
    expect(
      spec.restrictionViolatedBy(<String?>['109', 'CD', '19'])?.reason,
      notFound,
    );
    expect(
      () => spec.checkRestrictions(<String?>['109', 'CD', '19']),
      throwsA(isA<PlateRestrictionException>()),
    );
  });

  test('controller refuses mission 109 and accepts others', () {
    final c = PlateController.fromValues(spec, <String?>[null, 'CD', '19']);
    expect(c.setGroup('mission', '109'), isFalse);
    expect(c.rejection.value?.reason, notFound);
    expect(c.setGroup('mission', '52'), isTrue);
    c.dispose();
  });
}
