import 'dart:math';

import 'package:plate_core/plate_core.dart';

import 'british_virgin_islands_validators.dart';

/// Random values for fixtures and demos: one string per slot, the serial
/// sized to what the prefix takes.
abstract final class BritishVirginIslandsSerialGenerator {
  static List<String?> generate(PlateSpec spec, {Random? random}) {
    final Random rnd = random ?? Random();
    final PlateSlot prefixSlot = spec.slots[0];
    final String prefix = switch (spec.id) {
      'vg.private' => 'PV',
      'vg.government' => 'GV',
      'vg.commercial' => 'CM',
      _ => rnd.nextBool() ? 'TAXI' : 'TX',
    };
    assert(prefix.length >= prefixSlot.minLength);
    return <String?>[
      prefix,
      List<String>.generate(
        BritishVirginIslandsValidator.digitsFor(prefix),
        (_) => '${rnd.nextInt(10)}',
      ).join(),
    ];
  }
}
