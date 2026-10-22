import 'dart:math';

import 'package:plate_core/plate_core.dart';

/// Random values for fixtures and demos, one string per slot: five digits for
/// the modern plate; `TC` and 1–5 digits for the prefixed ones.
abstract final class TurksAndCaicosIslandsSerialGenerator {
  static List<String?> generate(PlateSpec spec, {Random? random}) {
    final Random rnd = random ?? Random();
    final PlateSlot digits = spec.slots.last;
    final int count = digits.minLength + rnd.nextInt(digits.length - digits.minLength + 1);
    final String serial = List<String>.generate(count, (_) => '${rnd.nextInt(10)}').join();
    return <String?>[if (spec.slots.length > 1) 'TC', serial];
  }
}
