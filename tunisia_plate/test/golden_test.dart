import 'dart:io';

import 'package:plate_core/plate_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tunisia_plate/tunisia_plate.dart';

/// One golden per category, drawn with real bold faces — DejaVu for digits
/// and Latin, Noto Sans Arabic for تونس and the suffixes, in one family so
/// glyphs fall back per character; Amiri for تونس — at 2 px per millimetre, so the ink can be
/// measured against the photos (see `_Layout` in `tunisia_plates.dart`).
///
/// Regenerate with `flutter test --update-goldens` after a deliberate change.
void main() {
  setUpAll(() async {
    final FontLoader loader = FontLoader('Roboto');
    for (final String path in const <String>[
      '/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf',
      '/usr/share/fonts/truetype/noto/NotoSansArabic-Bold.ttf',
    ]) {
      final File face = File(path);
      if (face.existsSync()) {
        loader.addFont(face.readAsBytes().then((b) => ByteData.view(b.buffer)));
      }
    }
    await loader.load();
    // تونس's own face, under the name a package font resolves to.
    final FontLoader amiri = FontLoader('packages/tunisia_plate/TunisiaAmiri')
      ..addFont(
        File(
          'assets/fonts/Amiri-Bold-tunis.ttf',
        ).readAsBytes().then((b) => ByteData.view(b.buffer)),
      );
    await amiri.load();
  });

  Future<void> render(
    WidgetTester tester, {
    required PlateSpec spec,
    required PlateTheme theme,
    required String values,
    required String name,
  }) async {
    final PlateController controller = PlateController.fromValues(spec, values.split(' '));
    tester.view.physicalSize = const Size(1200, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 2 * spec.canvasWidth,
              height: 2 * spec.canvasHeight,
              child: PlateThemeScope(
                theme: theme,
                child: PlateView(
                  controller: controller,
                  theme: theme,
                  country: TunisiaCountry.tunisia,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    // The military flag is decoded off the real event loop, which fake time
    // does not advance; runAsync gives it a real slice of time.
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pumpAndSettle();
    await expectLater(find.byType(PlateView), matchesGoldenFile('goldens/$name.png'));
    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
  }

  testWidgets('standard, 131 تونس 2180', (tester) async {
    await render(
      tester,
      spec: TunisiaPlates.standard,
      theme: TunisiaThemes.standard,
      values: '131 2180',
      name: 'tn_standard',
    );
  });

  testWidgets('standard, two-digit series', (tester) async {
    await render(
      tester,
      spec: TunisiaPlates.standard,
      theme: TunisiaThemes.standard,
      values: '73 3294',
      name: 'tn_standard_2',
    );
  });

  testWidgets('rental, 126 تونس 8202', (tester) async {
    await render(
      tester,
      spec: TunisiaPlates.standard,
      theme: TunisiaThemes.rental,
      values: '126 8202',
      name: 'tn_rental',
    );
  });

  testWidgets('square, 6069 / 47 تونس', (tester) async {
    await render(
      tester,
      spec: TunisiaPlates.square,
      theme: TunisiaThemes.standard,
      values: '6069 47',
      name: 'tn_square',
    );
  });

  testWidgets('square, three-digit series', (tester) async {
    await render(
      tester,
      spec: TunisiaPlates.square,
      theme: TunisiaThemes.standard,
      values: '6069 258',
      name: 'tn_square_3',
    );
  });

  testWidgets('government, 20 - 130486', (tester) async {
    await render(
      tester,
      spec: TunisiaPlates.government,
      theme: TunisiaThemes.government,
      values: '20 130486',
      name: 'tn_government',
    );
  });

  testWidgets('military, 21551', (tester) async {
    await render(
      tester,
      spec: TunisiaPlates.military,
      theme: TunisiaThemes.military,
      values: '21551',
      name: 'tn_military',
    );
  });

  for (final TunisiaMission m in TunisiaMission.values) {
    testWidgets('diplomatic ${m.latin}', (tester) async {
      await render(
        tester,
        spec: TunisiaPlates.diplomatic(m),
        theme: TunisiaThemes.diplomatic,
        values: m == TunisiaMission.chief ? '46 01' : '46 02',
        name: 'tn_diplomatic_${m.id}',
      );
    });
  }

  testWidgets('temporary, 73141 - ن ت', (tester) async {
    await render(
      tester,
      spec: TunisiaPlates.temporary(),
      theme: TunisiaThemes.standard,
      values: '73141',
      name: 'tn_temporary',
    );
  });

  // No dealer photo exists for its black-on-yellow, so there is no dealer
  // theme; this checks only the layout of `ع ع`.
  testWidgets('dealer layout, 12345 - ع ع', (tester) async {
    await render(
      tester,
      spec: TunisiaPlates.temporary(TunisiaSuffix.dealer),
      theme: TunisiaThemes.standard,
      values: '12345',
      name: 'tn_dealer_layout',
    );
  });

  test('series and government number are variable fields', () {
    expect(TunisiaPlates.standard.slots.length, 2);
    expect(TunisiaPlates.standard.slots.first.minLength, 1);
    expect(TunisiaPlates.standard.slots.first.length, 3);
    expect(TunisiaPlates.government.slots.last.length, 6);
    final PlateController c = PlateController.fromValues(TunisiaPlates.standard, ['7', '3294']);
    expect(c.isCompleted, isTrue);
    c.setAt(1, '329');
    expect(c.isCompleted, isFalse);
    c.dispose();
  });

  test('validator', () {
    bool ok(String series, String number) =>
        TunisiaValidator.validateFields(series: series, number: number) ==
        const PlateValidation.valid();
    expect(ok('131', '2180'), isTrue);
    expect(ok('73', '3294'), isTrue);
    expect(ok('031', '2180'), isFalse);
    expect(ok('131', '218'), isFalse);
    expect(ok('131', '0000'), isFalse);
  });

  test('generator fills every slot of every spec', () {
    for (final PlateSpec spec in <PlateSpec>[
      TunisiaPlates.standard,
      TunisiaPlates.square,
      TunisiaPlates.government,
      TunisiaPlates.diplomatic(),
      TunisiaPlates.military,
      TunisiaPlates.temporary(),
    ]) {
      expect(TunisiaSerialGenerator.generate(spec), everyElement(isNotNull));
    }
  });
}
