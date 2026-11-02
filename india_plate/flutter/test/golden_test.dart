import 'dart:io';

import 'package:plate_core/plate_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:india_plate/india_plate.dart';

/// One golden per format and colour class, rendered with a real font so the
/// row can be measured against the colour-class artwork.
///
/// Regenerate with `flutter test --update-goldens` after a deliberate change.
void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final loader = FontLoader('Roboto');
    final file = File('/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf');
    if (file.existsSync()) {
      loader.addFont(file.readAsBytes().then((b) => ByteData.view(b.buffer)));
    }
    await loader.load();
  });

  Future<void> renderGolden(
    WidgetTester tester,
    PlateSpec spec,
    PlateTheme theme,
    String value,
    String name,
  ) async {
    final controller = PlateController.fromValues(
      spec,
      value.split(' ').map<String?>((v) => v.isEmpty ? null : v).toList(),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 760,
              height: 760 * spec.canvasHeight / spec.canvasWidth,
              child: PlateThemeScope(
                theme: theme,
                child: PlateView(
                  controller: controller,
                  theme: theme,
                  country: IndiaCountry.india,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    // The chakra decal decodes off the real event loop, which fake time does
    // not advance; give it a real slice of time before the golden is taken.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(PlateView),
      matchesGoldenFile('goldens/$name.png'),
    );
    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
  }

  final cases = <(String, PlateSpec, PlateTheme, String)>[
    ('in_private', IndiaPlates.private, IndiaThemes.private, 'MH 20 DV 2366'),
    (
      'in_transport',
      IndiaPlates.standard,
      IndiaThemes.transport,
      'MH 12 DV 4353',
    ),
    ('in_rental', IndiaPlates.standard, IndiaThemes.rental, 'MH 09 DV 5346'),
    (
      'in_electric',
      IndiaPlates.standard,
      IndiaThemes.electric,
      'MH 04 DV 4321',
    ),
    (
      'in_electric_transport',
      IndiaPlates.standard,
      IndiaThemes.electricTransport,
      'MH 04 DV 4321',
    ),
    (
      'in_diplomatic',
      IndiaPlates.diplomatic,
      IndiaThemes.diplomatic,
      '052 CD 19',
    ),
    ('in_consular', IndiaPlates.diplomatic, IndiaThemes.consular, '199 CC 123'),
    ('in_bharat', IndiaPlates.bharat, IndiaThemes.private, '21 2345 AA'),
    ('in_vintage', IndiaPlates.vintage, IndiaThemes.private, 'MH AA 0000'),
    (
      'in_military',
      IndiaPlates.military,
      IndiaThemes.military,
      '02 B 084821 H',
    ),
    (
      'in_military_police',
      IndiaPlates.military,
      IndiaThemes.militaryPolice,
      '24 B 123456 Z',
    ),
    (
      'in_temporary',
      IndiaPlates.temporary,
      IndiaThemes.temporary,
      '1123 KL 5986 KA',
    ),
    ('in_trade', IndiaPlates.trade, IndiaThemes.trade, 'UP 16 C 0002 0073'),
  ];
  for (final (name, spec, theme, value) in cases) {
    testWidgets(name, (t) => renderGolden(t, spec, theme, value, name));
  }
}
