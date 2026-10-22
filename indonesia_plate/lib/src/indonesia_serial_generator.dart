import 'dart:math';

import 'package:plate_core/plate_core.dart';

import 'indonesia_validators.dart';

/// Fills the groups of an `IndonesiaPlates.car` or `motorcycle` spec. [area]
/// fixes the area code; otherwise one is drawn from [IndonesiaAreaCodes].
abstract final class IndonesiaSerialGenerator {
  static const String _letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

  static List<String?> generate(PlateSpec spec, {Random? random, String? area}) {
    final Random rnd = random ?? Random();
    final List<String?> values = List<String?>.filled(spec.slots.length, null);
    final List<String> codes = IndonesiaAreaCodes.all.toList();
    values[spec.indicesOfGroup('prefix').single] = area ?? codes[rnd.nextInt(codes.length)];

    final int digits = 1 + rnd.nextInt(4);
    values[spec.indicesOfGroup('number').single] = <String>[
      for (int i = 0; i < digits; i++) (i == 0 ? 1 + rnd.nextInt(9) : rnd.nextInt(10)).toString(),
    ].join();

    final int letters = 1 + rnd.nextInt(3);
    values[spec.indicesOfGroup('suffix').single] = <String>[
      for (int i = 0; i < letters; i++) _letters[rnd.nextInt(_letters.length)],
    ].join();

    values[spec.indicesOfGroup('month').single] = (1 + rnd.nextInt(12)).toString().padLeft(2, '0');
    values[spec.indicesOfGroup('year').single] = (26 + rnd.nextInt(5)).toString();
    return values;
  }
}
