import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:plate_core/plate_core.dart';
import 'package:vietnam_plate/vietnam_plate.dart';

void main() {
  test('Israel mission codes are refused by the spec', () {
    final PlateSpec spec = VietnamPlates.foreignLong();
    for (final String code in VietnamMissions.refused) {
      final List<String?> v = <String?>[
        '80', code, 'NG', '45', //
      ];
      expect(spec.restrictionViolatedBy(v), isNotNull, reason: code);
    }
    expect(VietnamMissions.isRefused('335'), isFalse);
    expect(VietnamMissions.isRefused('341'), isFalse);
    expect(VietnamPlates.foreignShort().restrictions, isNotEmpty);
  });

  test('the generator never emits a refused mission code', () {
    final Random rnd = Random(1);
    final PlateSpec spec = VietnamPlates.foreignLong();
    for (int n = 0; n < 2000; n++) {
      final List<String?> v = VietnamSerialGenerator.generate(spec, random: rnd);
      final String code = spec.indicesOfGroup('mission').map((i) => v[i]).join();
      expect(VietnamMissions.isRefused(code), isFalse);
    }
  });

  test('every spec has the groups the generator fills', () {
    for (final PlateSpec s in <PlateSpec>[
      VietnamPlates.long,
      VietnamPlates.short,
      VietnamPlates.motorcycle,
      VietnamPlates.temporary,
      VietnamPlates.foreignLong(codeFirst: true),
      VietnamPlates.foreignShort(),
      VietnamPlates.militaryLong,
      VietnamPlates.militaryShort,
      VietnamPlates.militaryMotorcycle,
    ]) {
      final List<String?> v = VietnamSerialGenerator.generate(s);
      expect(v.whereType<String>().length, s.slots.length, reason: s.id);
    }
  });

  test('a series completes from one letter; the number needs all five', () {
    final PlateController c = PlateController.fromValues(VietnamPlates.long, <String?>[
      '30',
      'F',
      '256',
      '58',
    ]);
    expect(c.isCompleted, isTrue);
    c.setAt(1, 'LD');
    expect(c.isCompleted, isTrue);
    c.setAt(3, '5');
    expect(c.isCompleted, isFalse);
    c.dispose();
  });
}
