import 'dart:math';

import 'package:plate_core/plate_core.dart';

/// Random values for fixtures and demos. On a civil spec, `type` is a class
/// ([vehicleClass]) plus a year 00–26 and `wilaya` is [wilaya] or a code
/// 01–58 (the ones issued before 2027).
abstract final class AlgeriaSerialGenerator {
  static List<String?> generate(PlateSpec spec, {Random? random, int? vehicleClass, int? wilaya}) {
    final Random rnd = random ?? Random();
    final List<String?> values = <String?>[
      for (final PlateSlot slot in spec.slots)
        List<String>.generate(slot.length, (_) => '${rnd.nextInt(10)}').join(),
    ];
    void fill(String key, String text) {
      if (spec.indicesOfGroup(key).singleOrNull case final int i) {
        values[i] = text;
      }
    }

    fill('type', '${vehicleClass ?? 1 + rnd.nextInt(9)}${_two(rnd.nextInt(27))}');
    fill('wilaya', _two(wilaya ?? 1 + rnd.nextInt(58)));
    return values;
  }

  static String _two(int n) => n.toString().padLeft(2, '0');
}
