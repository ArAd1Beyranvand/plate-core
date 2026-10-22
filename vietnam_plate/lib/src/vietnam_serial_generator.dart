import 'dart:math';

import 'package:plate_core/plate_core.dart';

import 'vietnam_missions.dart';

/// Generates plausible values for fixtures and demos. Pure Dart.
///
/// Fills every text group a Vietnam spec has with one string per slot:
/// province 11–99, a series of one or two letters (a digit allowed in the
/// second cell of a motorcycle series), a unit code, a number, and a mission
/// code that is never 336–340.
abstract final class VietnamSerialGenerator {
  static const String _series = 'ABCDEFGHKLMNPRSTUVXYZ';
  static const String _letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const String _digits = '0123456789';

  static List<String?> generate(PlateSpec spec, {Random? random}) {
    final Random rnd = random ?? Random();
    final List<String?> values = List<String?>.filled(spec.slots.length, null);
    String pick(String pool) => pool[rnd.nextInt(pool.length)];

    for (final PlateTextGroup group in spec.textGroups) {
      final String key = group.key ?? '';
      for (final int i in group.indices) {
        final PlateSlot slot = spec.slots[i];
        final int count = slot.minLength + rnd.nextInt(slot.length - slot.minLength + 1);
        values[i] = switch (key) {
          'province' => (11 + rnd.nextInt(89)).toString(),
          'mission' => _mission(rnd),
          'series' => List<String>.generate(count, (_) => pick(_series)).join(),
          // A motorcycle series' second cell is a letter or a digit.
          'series2' => rnd.nextBool() ? pick(_digits) : pick(_series),
          'unit' || 'status' => List<String>.generate(count, (_) => pick(_letters)).join(),
          _ => List<String>.generate(count, (_) => pick(_digits)).join(),
        };
      }
    }
    return values;
  }

  static String _mission(Random rnd) {
    String code;
    do {
      code = (100 + rnd.nextInt(900)).toString();
    } while (VietnamMissions.isRefused(code));
    return code;
  }
}
