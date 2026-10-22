import 'dart:math';

import 'package:plate_core/plate_core.dart';

/// Random values for fixtures and demos: a block digit 1–7, three digits.
abstract final class NorfolkIslandSerialGenerator {
  static List<String?> generate(PlateSpec spec, {Random? random}) {
    final Random rnd = random ?? Random();
    return <String?>[
      '${1 + rnd.nextInt(7)}',
      List<String>.generate(3, (_) => '${rnd.nextInt(10)}').join(),
    ];
  }
}
