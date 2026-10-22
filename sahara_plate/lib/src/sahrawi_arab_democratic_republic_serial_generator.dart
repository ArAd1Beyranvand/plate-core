import 'dart:math';

import 'package:plate_core/plate_core.dart';

/// Random values for fixtures and demos: one string per slot. A letter slot
/// is the fixed prefix of its length (`SH` or `GSH`).
abstract final class SahrawiArabDemocraticRepublicSerialGenerator {
  static List<String?> generate(PlateSpec spec, {Random? random}) {
    final Random rnd = random ?? Random();
    return <String?>[
      for (final PlateSlot slot in spec.slots)
        if (slot.alphabet.isNumeric)
          List<String>.generate(
            slot.minLength + rnd.nextInt(slot.length - slot.minLength + 1),
            (_) => '${rnd.nextInt(10)}',
          ).join()
        else
          slot.length == 3 ? 'GSH' : 'SH',
    ];
  }
}
