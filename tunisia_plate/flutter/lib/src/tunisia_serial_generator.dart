import 'dart:math';

import 'package:plate_core/plate_core.dart';

/// Fills every digit slot of any `TunisiaPlates` spec. A `series` group has no
/// leading zero and, at three digits, is drawn from the 2008-2026 series
/// (131-261); other groups are never all zeros. Pure Dart.
abstract final class TunisiaSerialGenerator {
  static List<String?> generate(PlateSpec spec, {Random? random}) {
    final Random rnd = random ?? Random();
    final List<String?> values = List<String?>.filled(spec.slots.length, null);
    for (final PlateTextGroup group in spec.textGroups) {
      final PlateSlot slot = spec.slots[group.indices.single];
      final int n =
          slot.minLength + rnd.nextInt(slot.length - slot.minLength + 1);
      final String digits = switch (group.key) {
        'series' when slot.length == 3 && n == 3 =>
          (131 + rnd.nextInt(131)).toString(),
        'series' =>
          (pow(10, n - 1) + rnd.nextInt(9 * pow(10, n - 1).toInt())).toString(),
        _ => (1 + rnd.nextInt(pow(10, n).toInt() - 1)).toString().padLeft(
          n,
          '0',
        ),
      };
      values[group.indices.single] = digits;
    }
    return values;
  }
}
