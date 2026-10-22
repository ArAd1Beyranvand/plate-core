import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sahara_plate/sahara_plate.dart';
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
        'private': (
          SahrawiArabDemocraticRepublicPlates.private,
          SahrawiArabDemocraticRepublicThemes.private,
          'SH 30 13581',
        ),
        'private_white': (
          SahrawiArabDemocraticRepublicPlates.private,
          SahrawiArabDemocraticRepublicThemes.privateWhite,
          'SH 50 17321',
        ),
        'government': (
          SahrawiArabDemocraticRepublicPlates.government,
          SahrawiArabDemocraticRepublicThemes.government,
          'GSH 27 15316',
        ),
        'government_white': (
          SahrawiArabDemocraticRepublicPlates.government,
          SahrawiArabDemocraticRepublicThemes.governmentWhite,
          'GSH 21 14663',
        ),
        'army': (
          SahrawiArabDemocraticRepublicPlates.army,
          SahrawiArabDemocraticRepublicThemes.army,
          '141101364',
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
                    country: SahrawiArabDemocraticRepublicCountry.sahrawi_arab_democratic_republic,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(find.byType(PlateView), matchesGoldenFile('goldens/eh_${c.key}.png'));
      await tester.pumpWidget(const SizedBox.shrink());
      controller.dispose();
    });
  }
}
