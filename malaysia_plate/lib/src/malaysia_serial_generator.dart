import 'dart:math';

import 'package:plate_core/plate_core.dart';

/// Generates plausible values for fixtures and demos. Pure Dart.
///
/// Fills the `prefix`, `number` and `suffix` groups. [prefix] fixes the prefix
/// (`'W'`, `'SAA'`); omitted, letters are drawn from those issued (no I, O or
/// Z). Numbers have no leading zero.
abstract final class MalaysiaSerialGenerator {
  static const String _issued = 'ABCDEFGHJKLMNPQRSTUVWXY';

  static List<String?> generate(PlateSpec spec, {Random? random, String prefix = ''}) {
    final Random rnd = random ?? Random();
    final List<String?> values = List<String?>.filled(spec.slots.length, null);
    final int prefixSlot = _require(spec, 'prefix').first;
    final int numberSlot = _require(spec, 'number').first;
    final int prefixLength = prefix.isEmpty
        ? 1 + rnd.nextInt(spec.slots[prefixSlot].length)
        : prefix.length;
    values[prefixSlot] = <String>[
      for (int i = 0; i < prefixLength; i++)
        i < prefix.length ? prefix[i] : _issued[rnd.nextInt(_issued.length)],
    ].join();
    final int digits = 1 + rnd.nextInt(spec.slots[numberSlot].length);
    values[numberSlot] = <String>[
      for (int i = 0; i < digits; i++) (i == 0 ? 1 + rnd.nextInt(9) : rnd.nextInt(10)).toString(),
    ].join();
    for (final int i in spec.indicesOfGroup('suffix')) {
      values[i] = _issued[rnd.nextInt(_issued.length)];
    }
    return values;
  }
}

List<int> _require(PlateSpec spec, String key) {
  final List<int> indices = spec.indicesOfGroup(key);
  if (indices.isEmpty) {
    throw ArgumentError.value(spec.id, 'spec', 'has no text group named "$key"');
  }
  return indices;
}
