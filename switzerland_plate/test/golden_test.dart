import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:switzerland_plate/switzerland_plate.dart';
import 'package:plate_core/plate_core.dart';

/// One golden per category, drawn with real bold faces so the ink can be
/// measured against the references (`platekit golden-check`).
///
/// Regenerate with `flutter test --update-goldens` after a deliberate change.
void main() {
  setUpAll(() async {
    final FontLoader loader = FontLoader('Roboto');
    for (final String path in const <String>[
      '/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf',
    ]) {
      final File face = File(path);
      if (!face.existsSync()) continue;
      loader.addFont(face.readAsBytes().then((b) => ByteData.view(b.buffer)));
    }
    await loader.load();
  });

  /// category id -> (spec, theme, sample value: one space-separated token
  /// per slot, i.e. per field — `'AB 1234'`, never `'A B 1 2 3 4'`)
  final Map<String, (PlateSpec, PlateTheme, String)> cases =
      <String, (PlateSpec, PlateTheme, String)>{
        'high': (SwitzerlandPlates.high, SwitzerlandThemes.standard, 'ZH 123456'),
        'utility': (SwitzerlandPlates.high, SwitzerlandThemes.utility, 'ZH 4229'),
        'exceptional': (SwitzerlandPlates.high, SwitzerlandThemes.exceptional, 'BE 5678'),
        'dealer': (SwitzerlandPlates.dealer, SwitzerlandThemes.standard, 'TI 1234 U'),
        'temporary': (SwitzerlandPlates.temporary, SwitzerlandThemes.standard, 'VD 12345 06'),
        'long': (SwitzerlandPlates.long, SwitzerlandThemes.standard, 'SG 123456'),
        'red': (SwitzerlandPlates.long, SwitzerlandThemes.red, 'SG 123456'),
        'military': (SwitzerlandPlates.military, SwitzerlandThemes.military, 'M 123456'),
        'front': (SwitzerlandPlates.front, SwitzerlandThemes.standard, 'GR 1999'),
        'agricultural': (SwitzerlandPlates.front, SwitzerlandThemes.agricultural, 'TG 7'),
        'customs': (SwitzerlandPlates.customs, SwitzerlandThemes.standard, 'ZH 1 Z'),
        'motorcycle': (SwitzerlandPlates.motorcycle, SwitzerlandThemes.standard, 'SG 12345'),
        'scooter': (SwitzerlandPlates.scooter, SwitzerlandThemes.scooter, 'LU 4567'),
        'diplomatic': (SwitzerlandPlates.diplomatic, SwitzerlandThemes.diplomatic, 'CD GE 29 201'),
        'consular': (SwitzerlandPlates.consular, SwitzerlandThemes.diplomatic, 'CC ZH 8 38'),
      };

  for (final MapEntry<String, (PlateSpec, PlateTheme, String)> c in cases.entries) {
    testWidgets(c.key, (tester) async {
      final (PlateSpec spec, PlateTheme theme, String values) = c.value;
      final PlateController controller = PlateController.fromValues(spec, values.split(' '));
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 680,
                height: 300,
                child: PlateThemeScope(
                  theme: theme,
                  child: PlateView(
                    controller: controller,
                    theme: theme,
                    country: SwitzerlandCountry.switzerland,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(find.byType(PlateView), matchesGoldenFile('goldens/ch_${c.key}.png'));
      await tester.pumpWidget(const SizedBox.shrink());
      controller.dispose();
    });
  }
}
