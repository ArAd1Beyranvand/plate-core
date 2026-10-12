import 'dart:math';

import 'package:plate_core/plate_core.dart';

import 'yemen_governorates.dart';

/// Makes plate values that satisfy `YemenUnifiedValidator`. For demos, fixtures, goldens.
/// Pure Dart, no Flutter. Pass a seeded [Random] for repeatable sequences.
/// Well-formed but not registered. Output drops into [PlateController] or [ShowPlate].
abstract final class YemenUnifiedSerialGenerator {
  /// A value for [spec] — vehicle number and side code, positioned by spec's text groups.
  /// Throws [ArgumentError] if [spec] has no `number` and `sideCode` groups.
  /// Side code is two uniform digits (not constrained to 1..22; see TODO in validator).
  static List<String?> generate(PlateSpec spec, {Random? random}) {
    final Random rnd = random ?? Random();
    final List<String?> values = List<String?>.filled(spec.slots.length, null);

    final List<int> number = _require(spec, 'number');
    final List<int> sideCode = _require(spec, 'sideCode');

    _fill(spec, values, number, () => rnd.nextInt(10).toString(), rnd);
    _fill(spec, values, sideCode, () => rnd.nextInt(10).toString(), rnd);

    return values;
  }

  /// [count] values for [spec], each one independently generated.
  static List<List<String?>> generateMany(
    PlateSpec spec,
    int count, {
    Random? random,
  }) {
    final Random rnd = random ?? Random();
    return List<List<String?>>.generate(
      count,
      (_) => generate(spec, random: rnd),
      growable: false,
    );
  }
}

/// Makes plate values that satisfy `YemenNorthernValidator`.
/// Honours both constraints: governorate code 1..22, serial never zero-padded.
/// See [YemenUnifiedSerialGenerator] for the general contract.
abstract final class YemenNorthernSerialGenerator {
  /// A value for [spec] — governorate code and serial, positioned by spec's text groups.
  /// Governorate drawn uniformly from 1..22; serial a random length within its field, no leading zero.
  /// Throws [ArgumentError] if [spec] has no `governorate` and `serial` groups.
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

    // No leading zero: the first digit runs 1..9.
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
    final Random rnd = random ?? Random();
    return List<List<String?>>.generate(
      count,
      (_) => generate(spec, random: rnd),
      growable: false,
    );
  }
}

// Fills each slot in [indices] with a run of a random length between the
// slot's minLength and length.
void _fill(
  PlateSpec spec,
  List<String?> values,
  List<int> indices,
  String Function() digit,
  Random rnd,
) {
  for (final int i in indices) {
    final PlateSlot slot = spec.slots[i];
    final int length =
        slot.minLength + rnd.nextInt(slot.length - slot.minLength + 1);
    values[i] = [for (int c = 0; c < length; c++) digit()].join();
  }
}

// Slot indices of spec's text group named key. Throws if group not found.
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
