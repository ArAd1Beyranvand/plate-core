import 'dart:math';

import 'package:plate_core/plate_core.dart';

import 'lebanon_letters.dart';
import 'lebanon_usage.dart';
import 'lebanon_validators.dart';

/// Generates valid plate values for fixtures and tests. Pure Dart.
/// Pass a seeded `random` for repeatability.
abstract final class LebanonSerialGenerator {
  /// One string per slot of [spec].
  ///
  /// [letter] or [usage] fixes the letter; passing both is an error. Otherwise
  /// the letter is drawn from those currently issued. MP numbers are 1..128;
  /// others fill the slot with a non-zero leading digit.
  ///
  /// Throws if [spec] lacks `letter` and `serial` groups.
  static List<String?> generate(
    PlateSpec spec, {
    Random? random,
    LebanonLetter? letter,
    LebanonUsage? usage,
  }) {
    if (letter != null && usage?.letter != null) {
      throw ArgumentError('Pass letter: or usage:, not both — they would disagree.');
    }
    final Random rnd = random ?? Random();
    final List<String?> values = List<String?>.filled(spec.slots.length, null);

    final List<int> letterSlots = _require(spec, 'letter');
    final List<int> serialSlots = _require(spec, 'serial');

    final String? fixed = usage?.letter;
    final LebanonLetter chosen =
        letter ??
        (fixed != null
            ? LebanonLetter.fromCharacter(fixed)!
            : _issued[rnd.nextInt(_issued.length)]);

    values[letterSlots.first] = chosen.character;
    values[serialSlots.first] = chosen == LebanonLetter.mp
        ? (1 + rnd.nextInt(LebanonValidator.maxParliamentNumber)).toString()
        : _number(spec.slots[serialSlots.first].length, rnd);

    return values;
  }

  static List<List<String?>> generateMany(
    PlateSpec spec,
    int count, {
    Random? random,
    LebanonLetter? letter,
    LebanonUsage? usage,
  }) {
    final Random rnd = random ?? Random();
    return List<List<String?>>.generate(
      count,
      (_) => generate(spec, random: rnd, letter: letter, usage: usage),
      growable: false,
    );
  }

  static final List<LebanonLetter> _issued = LebanonLetter.values
      .where((LebanonLetter l) => l.inUse)
      .toList(growable: false);

  static String _number(int length, Random rnd) {
    final StringBuffer buffer = StringBuffer((1 + rnd.nextInt(9)).toString());
    for (int i = 1; i < length; i++) {
      buffer.write(rnd.nextInt(10));
    }
    return buffer.toString();
  }
}

List<int> _require(PlateSpec spec, String key) {
  final List<int> indices = spec.indicesOfGroup(key);
  if (indices.isEmpty) {
    throw ArgumentError.value(spec.id, 'spec', 'has no text group named "$key"');
  }
  return indices;
}
