import 'package:flutter_test/flutter_test.dart';
import 'package:mali_plate/mali_plate.dart';
import 'package:plate_core/plate_core.dart';

void main() {
  group('Mali Plates', () {
    test('standard plate spec exists', () {
      final spec = MaliPlates.all['standard']!();
      expect(spec.slots.length, 3);
    });

    test('validator exists', () {
      const validator = MaliValidator();
      expect(validator.gateGroup, 'suffix');
    });

    test('the validator waits for the suffix, then wants 2-4-2', () {
      const validator = MaliValidator();
      final spec = MaliPlates.all['standard']!();
      bool valid(List<String?> v) =>
          validator.validate(PlateEntry(spec: spec, values: v)).isValid;
      expect(valid(<String?>['AB', '1234', null]), isTrue, reason: 'quiet');
      expect(valid(<String?>['AB', '1234', 'MD']), isTrue);
      expect(valid(<String?>['AB', '123', 'MD']), isFalse);
    });

    test('theme exists', () {
      expect(MaliThemes.standard.ink, MaliColors.black);
    });
  });
}
