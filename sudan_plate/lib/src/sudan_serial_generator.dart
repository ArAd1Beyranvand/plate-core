import 'dart:math';

import 'package:plate_core/plate_core.dart';

/// Generates plausible values for fixtures and demos. Pure Dart.
abstract final class SudanSerialGenerator {
  static List<String?> generate(PlateSpec spec, {Random? random}) {
    final Random rnd = random ?? Random();
    String pick(PlateSlot slot) =>
        slot.alphabet.characters[rnd.nextInt(slot.alphabet.characters.length)];
    return <String?>[
      for (final PlateSlot slot in spec.slots)
        List<String>.generate(
          slot.minLength + rnd.nextInt(slot.length - slot.minLength + 1),
          (_) => pick(slot),
        ).join(),
    ];
  }
}
