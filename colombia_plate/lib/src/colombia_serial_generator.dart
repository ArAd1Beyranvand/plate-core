import 'dart:math';

import 'package:plate_core/plate_core.dart';

import 'colombia_plates.dart';

/// Generates plausible values for fixtures and demos. Pure Dart.
///
/// Fills every slot of any `ColombiaPlates` spec from its own alphabet. A
/// series' letter field starts with the series' fixed letters.
abstract final class ColombiaSerialGenerator {
  static List<String?> generate(PlateSpec spec, {Random? random}) {
    final Random rnd = random ?? Random();
    final String fixed =
        ColombiaSeries.values
            .where((ColombiaSeries s) => spec.id == 'co.${s.id}')
            .lastOrNull
            ?.fixed ??
        '';
    return <String?>[
      for (final PlateSlot slot in spec.slots)
        () {
          final List<String> chars = slot.alphabet.characters;
          final bool letters = chars.length > 10;
          final String head = letters ? fixed : '';
          return head +
              List<String>.generate(
                slot.length - head.length,
                (_) => chars[rnd.nextInt(chars.length)],
              ).join();
        }(),
    ];
  }
}
