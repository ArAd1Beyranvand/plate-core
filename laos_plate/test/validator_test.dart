import 'package:flutter_test/flutter_test.dart';
import 'package:laos_plate/laos_plate.dart';
import 'package:plate_core/plate_core.dart';

PlateValidation check(PlateValidator v, PlateSpec spec, String values) =>
    v.validate(PlateEntry(spec: spec, values: values.split(' ')));

void main() {
  test('every category builds with the groups its validator reads', () {
    for (final LaosCategory c in LaosCategory.values) {
      final PlateSpec spec = LaosPlates.of(c);
      expect(spec.indicesOfGroup('serial'), isNotEmpty, reason: c.id);
    }
    expect(LaosPlates.all, hasLength(LaosCategory.values.length));
  });

  test('every province builds its own provincial spec', () {
    final Set<String> ids = <String>{
      for (final LaosProvince p in LaosProvince.values)
        LaosPlates.of(LaosCategory.private, province: p).id,
    };
    expect(ids, hasLength(LaosProvince.values.length));
  });

  test('provincial: photographed registers pass, class letter checked', () {
    const LaosValidator v = LaosValidator();
    final PlateSpec spec = LaosPlates.private;
    expect(check(v, spec, 'ຮ ຍ 8118').isValid, isTrue);
    expect(check(v, spec, 'ກ ກ 6884').isValid, isTrue);
    expect(check(v, spec, 'ຊ ກ 1234').reason, LaosValidator.reasonClass);
    expect(check(v, spec, 'ກ ກ 123').reason, LaosValidator.reasonSerial);
  });

  test('temporary: the photographed plate passes', () {
    const LaosTemporaryValidator v = LaosTemporaryValidator();
    final PlateSpec spec = LaosPlates.temporary;
    expect(check(v, spec, 'ຊ ຄ 3 248 10 2024 01').isValid, isTrue);
    expect(check(v, spec, 'ຊ ຄ 3 248 10 2024').reason, LaosTemporaryValidator.reasonExpiry);
  });

  test('prefixed: 2-2 on international plates, 4 on police', () {
    const LaosPrefixedValidator v = LaosPrefixedValidator();
    expect(check(v, LaosPlates.diplomatic, '23 14').isValid, isTrue);
    expect(check(v, LaosPlates.publicSecurity, '0549').isValid, isTrue);
    expect(check(v, LaosPlates.publicSecurity, '054').reason, LaosPrefixedValidator.reasonSerial);
  });

  test('an empty plate is not judged', () {
    final PlateSpec spec = LaosPlates.private;
    expect(
      const LaosValidator()
          .validate(PlateEntry(spec: spec, values: List<String?>.filled(3, null)))
          .isValid,
      isTrue,
    );
  });
}
