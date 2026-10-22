import 'dart:math';

import 'package:plate_core/plate_core.dart';

/// Random values for fixtures and demos: letter `A`, then 1–4 digits.
abstract final class AnguillaSerialGenerator {
  static List<String?> generate(PlateSpec spec, {Random? random}) {
    final Random rnd = random ?? Random();
    final PlateSlot digits = spec.slots[1];
    final int count = digits.minLength + rnd.nextInt(digits.length - digits.minLength + 1);
    return <String?>['A', List<String>.generate(count, (_) => '${rnd.nextInt(10)}').join()];
  }
}
