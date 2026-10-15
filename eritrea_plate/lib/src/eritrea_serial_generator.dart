import 'dart:math';

import 'package:plate_core/plate_core.dart';

/// Plausible values for fixtures and demos: the disc digit, then the five-digit number.
abstract final class EritreaSerialGenerator {
  static List<String?> generate(PlateSpec spec, {Random? random}) {
    final Random rnd = random ?? Random();
    final String number = (1 + rnd.nextInt(99999)).toString().padLeft(5, '0');
    return <String?>['${1 + rnd.nextInt(9)}', number];
  }
}
