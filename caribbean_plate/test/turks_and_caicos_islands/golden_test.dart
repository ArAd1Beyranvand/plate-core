import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:caribbean_plate/caribbean_plate.dart';
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
        'private_black': (
          TurksAndCaicosIslandsPlates.modern,
          TurksAndCaicosIslandsThemes.privateBlack,
          '12345',
        ),
        'private_red': (
          TurksAndCaicosIslandsPlates.modern,
          TurksAndCaicosIslandsThemes.privateRed,
          '41400',
        ),
        'private_legacy': (
          TurksAndCaicosIslandsPlates.prefixed,
          TurksAndCaicosIslandsThemes.privateRed,
          'TC 1234',
        ),
        'commercial': (
          TurksAndCaicosIslandsPlates.prefixed,
          TurksAndCaicosIslandsThemes.commercial,
          'TC 1234',
        ),
        'government': (
          TurksAndCaicosIslandsPlates.prefixed,
          TurksAndCaicosIslandsThemes.government,
          'TC 1234',
        ),
        'self_drive': (
          TurksAndCaicosIslandsPlates.selfDrive,
          TurksAndCaicosIslandsThemes.selfDrive,
          'TC 1234',
        ),
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
                    country: TurksAndCaicosIslandsCountry.turks_and_caicos_islands,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(find.byType(PlateView), matchesGoldenFile('goldens/tc_${c.key}.png'));
      await tester.pumpWidget(const SizedBox.shrink());
      controller.dispose();
    });
  }
}
