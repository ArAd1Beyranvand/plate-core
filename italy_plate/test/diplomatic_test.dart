import 'package:flutter_test/flutter_test.dart';
import 'package:italy_plate/italy_plate.dart';
import 'package:plate_core/plate_core.dart';

void main() {
  const notFound = 'COUNTRY NOT FOUND';
  final spec = ItalyPlates.diplomatic;

  test('spec refuses code HL', () {
    expect(spec.restrictions, contains(ItalyMissions.restriction));
    expect(spec.restrictionViolatedBy(<String?>['0213', 'HL'])?.reason, notFound);
    expect(spec.restrictionViolatedBy(<String?>['0213', 'XG']), isNull);
    expect(
      () => spec.checkRestrictions(<String?>['0213', 'HL']),
      throwsA(isA<PlateRestrictionException>()),
    );
  });

  test('every diplomatic spec carries the restriction', () {
    for (final s in <PlateSpec>[
      ItalyPlates.diplomatic,
      ItalyPlates.consular,
      ItalyPlates.unitedNations,
      ItalyPlates.unitedNationsSpecialists,
      ItalyPlates.unitedNationsTransit,
    ]) {
      expect(s.restrictions, contains(ItalyMissions.restriction), reason: s.id);
    }
  });

  test('controller refuses HL and accepts XG', () {
    final c = PlateController.fromValues(spec, <String?>['0213', null]);
    expect(c.setGroup('code', 'HL'), isFalse);
    expect(c.rejection.value?.reason, notFound);
    expect(c.setGroup('code', 'XG'), isTrue);
    c.dispose();
  });

  test('validator', () {
    const v = ItalyDiplomaticValidator();
    expect(v.validate(PlateEntry(spec: spec, values: <String?>['0213', 'XG'])).isValid, isTrue);
    expect(v.validate(PlateEntry(spec: spec, values: <String?>['021', 'XG'])).isValid, isFalse);
  });
}
