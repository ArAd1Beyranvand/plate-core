import 'dart:math';

import 'package:plate_core/plate_core.dart';

import 'palestine_governorates.dart';
import 'palestine_usage.dart';

/// Synthetic serials for demos and tests, one generator per scheme, drawn from
/// the sets the validators accept. Pass a seeded [Random] to reproduce.
abstract final class PSSerialGenerator {
  /// Throws [ArgumentError] if [spec] lacks a required text group.
  static List<String?> modernWestBank(PlateSpec spec, {Random? random}) {
    final rng = random ?? Random();
    final values = List<String?>.filled(spec.slots.length, null);
    final region = _require(spec, 'region');
    final serial = _require(spec, 'serial');
    final governorate = _require(spec, 'governorate');

    for (final i in region) {
      values[i] = _digit(rng);
    }
    for (final i in serial) {
      values[i] = _digits(rng, 4);
    }
    final letters = PSGovernorate.letters;
    for (final i in governorate) {
      values[i] = letters[rng.nextInt(letters.length)];
    }
    return values;
  }

  static List<String?> legacyWestBank(PlateSpec spec, {Random? random}) {
    final rng = random ?? Random();
    final values = List<String?>.filled(spec.slots.length, null);
    final district = _require(spec, 'district');
    final serial = _require(spec, 'serial');
    final usage = _require(spec, 'usage');

    final districtCodes = PSLegacyUsage.districtCodes;
    for (final i in district) {
      values[i] = districtCodes[rng.nextInt(districtCodes.length)];
    }
    for (final i in serial) {
      values[i] = _digits(rng, 4);
    }
    final code = PSLegacyUsage.codes[rng.nextInt(PSLegacyUsage.codes.length)];
    for (final i in usage) {
      values[i] = code;
    }
    return values;
  }

  /// Gaza prefix is always `3`.
  static List<String?> gaza(PlateSpec spec, {Random? random}) {
    final rng = random ?? Random();
    final values = List<String?>.filled(spec.slots.length, null);
    final prefix = _require(spec, 'prefix');
    final serial = _require(spec, 'serial');
    final usage = _require(spec, 'usage');

    for (final i in prefix) {
      values[i] = '3';
    }
    for (final i in serial) {
      values[i] = _digits(rng, 4);
    }
    final code = PSGazaUsage.codes[rng.nextInt(PSGazaUsage.codes.length)];
    for (final i in usage) {
      values[i] = code;
    }
    return values;
  }

  static List<int> _require(PlateSpec spec, String key) {
    final indices = spec.indicesOfGroup(key);
    if (indices.isEmpty) {
      throw ArgumentError.value(spec.id, 'spec', 'has no text group named "$key"');
    }
    return indices;
  }

  static String toFilename(List<String?> values) => values.map((v) => v ?? '').join();

  static String _digit(Random rng) => rng.nextInt(10).toString();

  static String _digits(Random rng, int n) => List.generate(n, (_) => _digit(rng)).join();
}
