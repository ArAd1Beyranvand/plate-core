import 'package:flutter_test/flutter_test.dart';
import 'package:plate_core/plate_core.dart';
import 'package:yemen_plate/yemen_plate.dart';

void main() {
  const v = YemenSouthernValidator();

  PlateValidation judge(PlateSpec spec, String digits) =>
      v.validate(PlateEntry(spec: spec, values: digits.split('')));

  test('every southern spec accepts a full number', () {
    for (final spec in <PlateSpec>[
      YemenGovernoratePlates.hadhramautTemporary,
      YemenGovernoratePlates.hadhramautPolice,
      YemenGovernoratePlates.shabwahMotorcycle,
      YemenGovernoratePlates.marib,
      YemenAdenPlates.oneLine,
      YemenAdenPlates.twoLine,
      YemenTaizPlates.temporary,
    ]) {
      final full = '1234567'.substring(0, spec.slotCount);
      expect(judge(spec, full).isValid, isTrue, reason: spec.id);
    }
  });

  test('the Hadhramaut serial is four or five digits', () {
    for (final serial in <String>['1234', '12345']) {
      final entry = PlateEntry(
        spec: YemenGovernoratePlates.hadhramaut,
        values: <String>[serial],
      );
      expect(v.validate(entry).isValid, isTrue, reason: serial);
    }
    expect(YemenGovernoratePlates.hadhramaut.slots.single.minLength, 4);
  });

  test('length and digits are judged', () {
    expect(
      YemenSouthernValidator.validateFields(serial: '12').reason,
      YemenSouthernValidator.reasonSerialLength,
    );
    expect(
      YemenSouthernValidator.validateFields(serial: '123456').reason,
      YemenSouthernValidator.reasonSerialLength,
    );
    expect(
      YemenSouthernValidator.validateFields(serial: '12a4').reason,
      YemenSouthernValidator.reasonSerialNotNumeric,
    );
  });
}
