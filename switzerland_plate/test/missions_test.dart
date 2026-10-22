import 'package:flutter_test/flutter_test.dart';
import 'package:plate_core/plate_core.dart';
import 'package:switzerland_plate/switzerland_plate.dart';

void main() {
  test('code 7 is refused by the controller, the spec and the validator', () {
    final PlateController c = PlateController.fromValues(SwitzerlandPlates.diplomatic, <String?>[
      'CD',
      'GE',
      '29',
      null,
    ]);
    expect(c.setAt(3, '7'), isFalse);
    expect(c.setAt(3, '8'), isTrue);
    c.dispose();
    expect(
      () => SwitzerlandPlates.diplomatic.checkRestrictions(<String?>['CD', 'GE', '29', '7']),
      throwsA(isA<PlateRestrictionException>()),
    );
    expect(
      const SwitzerlandDiplomaticValidator()
          .validate(
            PlateEntry(
              spec: SwitzerlandPlates.diplomatic,
              values: <String?>['CD', 'GE', '29', '7'],
            ),
          )
          .reason,
      SwitzerlandMissions.notFound,
    );
  });
}
