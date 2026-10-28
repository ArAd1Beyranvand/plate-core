import 'dart:math';

import 'package:plate_core/plate_core.dart';

import 'yemen_governorates.dart';

/// Makes values that satisfy `YemenUnifiedValidator`, for demos, fixtures and
/// goldens. Well-formed but not registered; pass a seeded [Random] to repeat.
abstract final class YemenUnifiedSerialGenerator {
  /// A value for [spec]; throws [ArgumentError] without `number` and `sideCode`
  /// groups. The side code is unconstrained digits.
  static List<String?> generate(PlateSpec spec, {Random? random}) {
    final Random rnd = random ?? Random();
    final List<String?> values = List<String?>.filled(spec.slots.length, null);

    final List<int> number = _require(spec, 'number');
    final List<int> sideCode = _require(spec, 'sideCode');

    _fill(spec, values, number, rnd);
    _fill(spec, values, sideCode, rnd);

    return values;
  }

  /// [count] values for [spec], each one independently generated.
  static List<List<String?>> generateMany(
    PlateSpec spec,
    int count, {
    Random? random,
  }) {
    return _many(spec, count, random, generate);
  }
}

/// Makes values that satisfy `YemenNorthernValidator`; see
/// [YemenUnifiedSerialGenerator].
abstract final class YemenNorthernSerialGenerator {
  /// A value for [spec]; throws [ArgumentError] without `governorate` and
  /// `serial` groups. The serial has no leading zero.
  static List<String?> generate(PlateSpec spec, {Random? random}) {
    final Random rnd = random ?? Random();
    final List<String?> values = List<String?>.filled(spec.slots.length, null);

    final List<int> governorate = _require(spec, 'governorate');
    final List<int> serial = _require(spec, 'serial');

    final String code =
        (YemenGovernorate.minCode +
                rnd.nextInt(
                  YemenGovernorate.maxCode - YemenGovernorate.minCode + 1,
                ))
            .toString();
    values[governorate.single] = code;

    final PlateSlot field = spec.slots[serial.single];
    final int length =
        field.minLength + rnd.nextInt(field.length - field.minLength + 1);
    values[serial.single] = [
      for (int i = 0; i < length; i++)
        (i == 0 ? 1 + rnd.nextInt(9) : rnd.nextInt(10)).toString(),
    ].join();

    return values;
  }

  /// [count] values for [spec], each one independently generated.
  static List<List<String?>> generateMany(
    PlateSpec spec,
    int count, {
    Random? random,
  }) {
    return _many(spec, count, random, generate);
  }
}

List<List<String?>> _many(
  PlateSpec spec,
  int count,
  Random? random,
  List<String?> Function(PlateSpec, {Random? random}) generate,
) {
  final Random rnd = random ?? Random();
  return List<List<String?>>.generate(
    count,
    (_) => generate(spec, random: rnd),
    growable: false,
  );
}

// Fills each slot in [indices] with random digits of a random length from the
// slot's minLength to its length.
void _fill(
  PlateSpec spec,
  List<String?> values,
  List<int> indices,
  Random rnd,
) {
  for (final int i in indices) {
    final PlateSlot slot = spec.slots[i];
    final int length =
        slot.minLength + rnd.nextInt(slot.length - slot.minLength + 1);
    values[i] = [for (int c = 0; c < length; c++) rnd.nextInt(10)].join();
  }
}

List<int> _require(PlateSpec spec, String key) {
  final List<int> indices = spec.indicesOfGroup(key);
  if (indices.isEmpty) {
    throw ArgumentError.value(
      spec.id,
      'spec',
      'has no text group named "$key"',
    );
  }
  return indices;
}
