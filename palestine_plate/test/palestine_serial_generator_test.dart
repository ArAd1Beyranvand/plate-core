import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:palestine_plate/palestine_plate.dart';

void main() {
  const iterations = 10000;

  test('10000 generated modern West Bank serials all validate', () {
    final rng = Random(1);
    for (var i = 0; i < iterations; i++) {
      final values = PSSerialGenerator.modernWestBank(
        PSWestBankPlates.modernCar,
        random: rng,
      );
      final v = PSWestBankModernValidator.validateFields(
        region: values[0]!,
        serial: values[1]!,
        governorate: values[2]!,
      );
      expect(v.isValid, isTrue, reason: '$values: ${v.reason}');
    }
  });

  test('10000 generated legacy West Bank serials all validate', () {
    final rng = Random(2);
    for (var i = 0; i < iterations; i++) {
      final values = PSSerialGenerator.legacyWestBank(
        PSWestBankPlates.legacyCar,
        random: rng,
      );
      final v = PSWestBankLegacyValidator.validateFields(
        district: values[0]!,
        serial: values[1]!,
        usage: values[2]!,
      );
      expect(v.isValid, isTrue, reason: '$values: ${v.reason}');
    }
  });

  test('10000 generated Gaza serials all validate', () {
    final rng = Random(3);
    for (var i = 0; i < iterations; i++) {
      final values = PSSerialGenerator.gaza(PSGazaPlates.car2012, random: rng);
      final v = PSGazaValidator.validateFields(
        prefix: values[0]!,
        serial: values[1]!,
        usage: values[2]!,
      );
      expect(v.isValid, isTrue, reason: '$values: ${v.reason}');
    }
  });

  test('the generator never emits I, O or a reserved Gaza letter', () {
    final rng = Random(4);
    for (var i = 0; i < iterations; i++) {
      final letter = PSSerialGenerator.modernWestBank(
        PSWestBankPlates.modernCar,
        random: rng,
      )[2];
      expect(PSGovernorate.confusableLetters, isNot(contains(letter)));
      expect(PSGovernorate.reservedGazaLetters, isNot(contains(letter)));
    }
  });

  test('the generator never emits a Gaza prefix other than 3', () {
    final rng = Random(5);
    for (var i = 0; i < iterations; i++) {
      expect(PSSerialGenerator.gaza(PSGazaPlates.car2012, random: rng)[0], '3');
    }
  });

  test('writes each field into the slot its spec names', () {
    final spec = PSWestBankPlates.modernCar;
    final values = PSSerialGenerator.modernWestBank(spec, random: Random(1));
    expect(values.length, spec.slots.length);
    expect(values.every((v) => v != null), isTrue);
    // The governorate letter lands in the governorate group, not at a fixed index.
    for (final i in spec.indicesOfGroup('governorate')) {
      expect(PSGovernorate.letters, contains(values[i]));
    }
    for (final i in spec.indicesOfGroup('serial')) {
      expect(values[i], matches(RegExp(r'^[0-9]{4}$')));
    }
  });

  test('throws a clear ArgumentError when handed the wrong spec', () {
    expect(
      () => PSSerialGenerator.modernWestBank(PSGazaPlates.car2012),
      throwsArgumentError,
    );
  });

  test('toFilename concatenates with no separator', () {
    expect(PSSerialGenerator.toFilename(['1', '0234', 'H']), '10234H');
  });
}
