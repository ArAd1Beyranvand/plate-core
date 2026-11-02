import 'dart:math';

import 'package:plate_core/plate_core.dart';

/// Fills every slot of any `BoliviaPlates` spec from its own alphabet. A
/// four-digit PTA number is drawn below 6500, the series reached in 2024.
abstract final class BoliviaSerialGenerator {
  static List<String?> generate(PlateSpec spec, {Random? random}) {
    final Random rnd = random ?? Random();
    return <String?>[
      for (int i = 0; i < spec.slots.length; i++)
        if (i == 0 && spec.id.startsWith('bo.pta') && spec.slots[i].length == 4)
          rnd.nextInt(6500).toString().padLeft(4, '0')
        else
          _fill(spec.slots[i], rnd),
    ];
  }

  static String _fill(PlateSlot slot, Random rnd) {
    final List<String> chars = slot.alphabet.characters;
    return List<String>.generate(
      slot.length,
      (_) => chars[rnd.nextInt(chars.length)],
    ).join();
  }
}
