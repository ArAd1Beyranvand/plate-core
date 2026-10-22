import 'dart:math';

import 'package:plate_core/plate_core.dart';

import 'switzerland_missions.dart';
import 'switzerland_validators.dart';

/// Generates plausible values for fixtures and demos. Pure Dart.
///
/// One string per slot: a canton code, digits without a leading zero of a
/// random length between the slot's `minLength` and `length`, the fixed `U` /
/// `Z` marks, and for a diplomatic plate a prefix and a code that is never
/// refused.
abstract final class SwitzerlandSerialGenerator {
  static List<String?> generate(PlateSpec spec, {Random? random}) {
    final Random rnd = random ?? Random();
    final List<String?> values = List<String?>.filled(spec.slots.length, null);
    String digits(PlateSlot slot) {
      final int n = slot.minLength + rnd.nextInt(slot.length - slot.minLength + 1);
      return <String>[
        for (int i = 0; i < n; i++) '${i == 0 ? 1 + rnd.nextInt(9) : rnd.nextInt(10)}',
      ].join();
    }

    for (int i = 0; i < spec.slots.length; i++) {
      final PlateSlot slot = spec.slots[i];
      if (slot.alphabet.input == AlphabetInput.chosen || slot.alphabet.characters.length == 1) {
        values[i] = slot.alphabet.characters.first;
      } else if (slot.alphabet.isNumeric) {
        String d;
        do {
          d = digits(slot);
        } while (SwitzerlandMissions.isRefused(d));
        values[i] = d;
      } else {
        values[i] = switzerlandCantons[rnd.nextInt(switzerlandCantons.length)];
      }
    }
    return values;
  }
}
