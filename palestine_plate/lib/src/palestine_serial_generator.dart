import 'dart:math';

import 'package:plate_core/plate_core.dart';

import 'palestine_governorates.dart';
import 'palestine_usage.dart';

/// Synthetic Palestinian plate serials for demos and reproducible tests.
/// Pure Dart (no Flutter beyond `dart:math.Random`) — runs in unit tests.
/// One generator per scheme, seeded for reproducibility. Values drawn from
/// same legal set validators accept (asserted in test/palestine_serial_generator_test.dart:
/// 10,000 round-trips per scheme). Returns `List<String?>` (PlateSpec.slots shape).
abstract final class PSSerialGenerator {
  /// Value for modern West Bank [spec]. Positions from spec's text groups.
  /// Throws ArgumentError if spec lacks required groups.
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

  /// Value for legacy West Bank [spec]. Usage code is one two-digit slot.
  /// Throws ArgumentError if spec lacks required groups.
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
    _writeUsage(
      values,
      usage,
      PSLegacyUsage.codes[rng.nextInt(PSLegacyUsage.codes.length)],
    );
    return values;
  }

  /// Value for Gaza [spec]. Prefix literal '3'. Throws ArgumentError if missing groups.
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
    _writeUsage(
      values,
      usage,
      PSGazaUsage.codes[rng.nextInt(PSGazaUsage.codes.length)],
    );
    return values;
  }

  static void _writeUsage(
    List<String?> values,
    List<int> indices,
    String code,
  ) {
    for (final i in indices) {
      values[i] = code;
    }
  }

  static List<int> _require(PlateSpec spec, String key) {
    final indices = spec.indicesOfGroup(key);
    if (indices.isEmpty) {
      throw ArgumentError.value(
        spec.id,
        'spec',
        'has no text group named "$key"',
      );
    }
    return indices;
  }

  /// Values joined with no separator (filename/dataset row shape, vs renderGroup's dotted).
  static String toFilename(List<String?> values) =>
      values.map((v) => v ?? '').join();

  static String _digit(Random rng) => rng.nextInt(10).toString();

  static String _digits(Random rng, int n) =>
      List.generate(n, (_) => _digit(rng)).join();
}
