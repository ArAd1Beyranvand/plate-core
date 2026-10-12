import 'dart:math';

import 'package:plate_core/plate_core.dart';

/// Generates plausible values for fixtures and demos. Pure Dart.
///
/// Fills every field with a random run of its length, then, on a civil spec,
/// makes the
/// `type` group a class ([vehicleClass], default random) plus a year
/// 00–26, and the `wilaya` group [wilaya] or a code 01–58 (the ones issued
/// before 2027).
abstract final class AlgeriaSerialGenerator {
  static List<String?> generate(
    PlateSpec spec, {
    Random? random,
    int? vehicleClass,
    int? wilaya,
  }) {
    final Random rnd = random ?? Random();
    final List<String?> values = <String?>[
      for (final PlateSlot slot in spec.slots)
        List<String>.generate(slot.length, (_) => '${rnd.nextInt(10)}').join(),
    ];
    void fill(String key, String text) {
      values[spec.indicesOfGroup(key).single] = text;
    }

    if (spec.indicesOfGroup('type').isNotEmpty) {
      final int year = rnd.nextInt(27);
      fill('type', '${vehicleClass ?? 1 + rnd.nextInt(9)}${_two(year)}');
    }
    if (spec.indicesOfGroup('wilaya').isNotEmpty) {
      fill('wilaya', _two(wilaya ?? 1 + rnd.nextInt(58)));
    }
    return values;
  }

  static String _two(int n) => n.toString().padLeft(2, '0');
}
