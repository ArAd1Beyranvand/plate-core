import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laos_plate/laos_plate.dart';
import 'package:plate_core/plate_core.dart';

/// One golden per category, drawn with real bold faces so the ink can be
/// measured against the flattened photos (see `_Layout` in `laos_plates.dart`).
///
/// Regenerate with `flutter test --update-goldens` after a deliberate change.
void main() {
  setUpAll(() async {
    final FontLoader loader = FontLoader('Roboto');
    for (final String path in const <String>[
      '/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf',
      '/usr/share/fonts/truetype/noto/NotoLoopedLao-Bold.ttf',
    ]) {
      final File face = File(path);
      if (!face.existsSync()) continue;
      loader.addFont(face.readAsBytes().then((b) => ByteData.view(b.buffer)));
    }
    await loader.load();
  });

  /// The photographed value of each category, where there is a photo.
  const Map<String, String> values = <String, String>{
    'private': 'ຮ ຍ 8118',
    'private_ev': 'ຂ ກ 4714',
    'government': 'ກ ກ 6884',
    'company': 'ອ ທ 1234',
    'company_ev': 'ອ ທ 0004',
    'taxable_company': 'ກ ກ 2662',
    'temporary': 'ຊ ຄ 3 248 10 2024 01',
    'diplomatic': '23 14',
    'foreign_guest': '12 34',
    'united_nations': '12 34',
    'financial_institution': '12 34',
    'public_security': '0549',
    'national_defence': '1234',
  };

  for (final LaosCategory category in LaosCategory.values) {
    testWidgets(category.name, (tester) async {
      final PlateSpec spec = LaosPlates.of(category);
      final PlateTheme theme = LaosPlates.themeOf(category);
      final PlateController controller = PlateController.fromValues(
        spec,
        values[category.id]!.split(' '),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 680,
                height: 300,
                child: PlateThemeScope(
                  theme: theme,
                  child: PlateView(controller: controller, theme: theme, country: LaosCountry.laos),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(find.byType(PlateView), matchesGoldenFile('goldens/la_${category.id}.png'));
      await tester.pumpWidget(const SizedBox.shrink());
      controller.dispose();
    });
  }
}
