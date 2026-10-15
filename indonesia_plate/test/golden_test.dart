import 'dart:io';
import 'dart:math';

import 'package:plate_core/plate_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:indonesia_plate/indonesia_plate.dart';

/// One golden per category, drawn with a real bold face so the ink can be
/// measured against the references (see `_Layout` in `indonesia_plates.dart`).
///
/// Regenerate with `flutter test --update-goldens` after a deliberate change.
void main() {
  setUpAll(() async {
    final FontLoader loader = FontLoader('Roboto');
    final File face = File(
      '/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf',
    );
    if (face.existsSync()) {
      loader.addFont(face.readAsBytes().then((b) => ByteData.view(b.buffer)));
    }
    await loader.load();
  });

  Future<void> render(
    WidgetTester tester, {
    required PlateSpec spec,
    required PlateTheme theme,
    required String values,
    required String name,
  }) async {
    final PlateController controller = PlateController.fromValues(
      spec,
      values.split(' '),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 520,
              height: 520 * spec.canvasHeight / spec.canvasWidth,
              child: PlateThemeScope(
                theme: theme,
                child: PlateView(
                  controller: controller,
                  theme: theme,
                  country: IndonesiaCountry.indonesia,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    // The crest and mark decals decode off the real event loop, which fake
    // time does not advance; runAsync gives them a real slice of time.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(PlateView),
      matchesGoldenFile('goldens/$name.png'),
    );
    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
  }

  testWidgets('private car', (tester) async {
    await render(
      tester,
      spec: IndonesiaPlates.car,
      theme: IndonesiaThemes.private,
      values: 'B 1945 PKL 08 28',
      name: 'id_car_private',
    );
  });

  testWidgets('public car', (tester) async {
    await render(
      tester,
      spec: IndonesiaPlates.car,
      theme: IndonesiaThemes.public,
      values: 'XX 1234 ABC 08 28',
      name: 'id_car_public',
    );
  });

  testWidgets('government car', (tester) async {
    await render(
      tester,
      spec: IndonesiaPlates.car,
      theme: IndonesiaThemes.government,
      values: 'XX 1234 ABC 08 28',
      name: 'id_car_govt',
    );
  });

  testWidgets('free-trade-zone car', (tester) async {
    await render(
      tester,
      spec: IndonesiaPlates.car,
      theme: IndonesiaThemes.freeTradeZone,
      values: 'BP 1234 ABC 08 28',
      name: 'id_car_ftz',
    );
  });

  testWidgets('private EV car', (tester) async {
    await render(
      tester,
      spec: IndonesiaPlates.carEv,
      theme: IndonesiaThemes.privateEv,
      values: 'XX 1234 ABC 08 28',
      name: 'id_car_private_ev',
    );
  });

  testWidgets('public EV car', (tester) async {
    await render(
      tester,
      spec: IndonesiaPlates.carEv,
      theme: IndonesiaThemes.publicEv,
      values: 'XX 1234 ABC 08 28',
      name: 'id_car_public_ev',
    );
  });

  testWidgets('government EV car', (tester) async {
    await render(
      tester,
      spec: IndonesiaPlates.carEv,
      theme: IndonesiaThemes.governmentEv,
      values: 'XX 1234 ABC 08 28',
      name: 'id_car_govt_ev',
    );
  });

  testWidgets('FTZ EV car', (tester) async {
    await render(
      tester,
      spec: IndonesiaPlates.carEv,
      theme: IndonesiaThemes.freeTradeZoneEv,
      values: 'XX 1234 ABC 08 28',
      name: 'id_car_ftz_ev',
    );
  });

  testWidgets('short car, B 1 A', (tester) async {
    await render(
      tester,
      spec: IndonesiaPlates.car,
      theme: IndonesiaThemes.private,
      values: 'B 1 A 01 28',
      name: 'id_car_short',
    );
  });

  testWidgets('private motorcycle', (tester) async {
    await render(
      tester,
      spec: IndonesiaPlates.motorcycle,
      theme: IndonesiaThemes.private,
      values: 'XX 1234 ABC 08 28',
      name: 'id_moto_private',
    );
  });

  testWidgets('public motorcycle', (tester) async {
    await render(
      tester,
      spec: IndonesiaPlates.motorcycle,
      theme: IndonesiaThemes.public,
      values: 'XX 1234 ABC 08 28',
      name: 'id_moto_public',
    );
  });

  testWidgets('government motorcycle', (tester) async {
    await render(
      tester,
      spec: IndonesiaPlates.motorcycle,
      theme: IndonesiaThemes.government,
      values: 'XX 1234 ABC 08 28',
      name: 'id_moto_govt',
    );
  });

  testWidgets('FTZ motorcycle', (tester) async {
    await render(
      tester,
      spec: IndonesiaPlates.motorcycle,
      theme: IndonesiaThemes.freeTradeZone,
      values: 'XX 1234 ABC 08 28',
      name: 'id_moto_ftz',
    );
  });

  testWidgets('private EV motorcycle', (tester) async {
    await render(
      tester,
      spec: IndonesiaPlates.motorcycleEv,
      theme: IndonesiaThemes.privateEv,
      values: 'XX 1234 ABC 08 28',
      name: 'id_moto_private_ev',
    );
  });

  testWidgets('public EV motorcycle', (tester) async {
    await render(
      tester,
      spec: IndonesiaPlates.motorcycleEv,
      theme: IndonesiaThemes.publicEv,
      values: 'XX 1234 ABC 08 28',
      name: 'id_moto_public_ev',
    );
  });

  testWidgets('government EV motorcycle', (tester) async {
    await render(
      tester,
      spec: IndonesiaPlates.motorcycleEv,
      theme: IndonesiaThemes.governmentEv,
      values: 'XX 1234 ABC 08 28',
      name: 'id_moto_govt_ev',
    );
  });

  testWidgets('FTZ EV motorcycle', (tester) async {
    await render(
      tester,
      spec: IndonesiaPlates.motorcycleEv,
      theme: IndonesiaThemes.freeTradeZoneEv,
      values: 'XX 1234 ABC 08 28',
      name: 'id_moto_ftz_ev',
    );
  });

  testWidgets('diplomatic', (tester) async {
    await render(
      tester,
      spec: IndonesiaPlates.diplomatic,
      theme: IndonesiaThemes.diplomatic,
      values: 'CD 123 123 08 28',
      name: 'id_diplomatic',
    );
  });

  testWidgets('diplomatic EV', (tester) async {
    await render(
      tester,
      spec: IndonesiaPlates.diplomatic,
      theme: IndonesiaThemes.diplomaticEv,
      values: 'CD 123 123 08 28',
      name: 'id_diplomatic_ev',
    );
  });

  for (final (IndonesiaService service, PlateTheme theme)
      in <(IndonesiaService, PlateTheme)>[
        (IndonesiaService.army, IndonesiaThemes.army),
        (IndonesiaService.navy, IndonesiaThemes.navy),
        (IndonesiaService.airForce, IndonesiaThemes.airForce),
        (IndonesiaService.armedForces, IndonesiaThemes.armedForces),
      ]) {
    testWidgets('military ${service.name}', (tester) async {
      await render(
        tester,
        spec: IndonesiaPlates.military(service),
        theme: theme,
        values: '75359 00',
        name: 'id_military_${service.id}',
      );
    });
  }

  testWidgets('military, four digits', (tester) async {
    await render(
      tester,
      spec: IndonesiaPlates.military(IndonesiaService.navy),
      theme: IndonesiaThemes.navy,
      values: '8191 00',
      name: 'id_military_navy_4',
    );
  });

  testWidgets('police', (tester) async {
    await render(
      tester,
      spec: IndonesiaPlates.police,
      theme: IndonesiaThemes.police,
      values: 'XXXIII 3705 40',
      name: 'id_police',
    );
  });

  test('service validator', () {
    PlateValidation judge(PlateSpec spec, String values) =>
        const IndonesiaServiceValidator().judge(
          PlateEntry(spec: spec, values: values.split(' ')),
        );
    final PlateSpec police = IndonesiaPlates.police;
    final PlateSpec army = IndonesiaPlates.military(IndonesiaService.army);
    expect(judge(police, 'XV 3705 40'), const PlateValidation.valid());
    expect(judge(police, 'XL 3705 40'), isNot(const PlateValidation.valid()));
    expect(judge(army, '75359 00'), const PlateValidation.valid());
    expect(judge(army, '05359 00'), isNot(const PlateValidation.valid()));
  });

  test('validator', () {
    bool ok(
      String prefix,
      String number, [
      String suffix = '',
      String month = '',
    ]) =>
        IndonesiaValidator.validateFields(
          prefix: prefix,
          number: number,
          suffix: suffix,
          month: month,
        ) ==
        const PlateValidation.valid();
    expect(ok('B', '1945', 'PKL', '01'), isTrue);
    expect(ok('XX', '1234'), isFalse);
    expect(ok('B', '0123'), isFalse);
    expect(ok('B', '1', '', '13'), isFalse);
  });

  test('fields are variable, and complete at their minimum', () {
    final PlateSpec spec = IndonesiaPlates.car;
    expect(spec.slotCount, 5);
    expect(spec.slots[0].length, 2);
    expect(spec.slots[0].minLength, 1);
    expect(spec.slots[1].length, 4);
    expect(spec.slots[2].length, 3);
    expect(
      IndonesiaPlates.military(IndonesiaService.army).slots[0].minLength,
      4,
    );
    expect(spec.slots[1].isComplete('1'), isTrue);
    expect(spec.slots[1].isComplete(null), isFalse);
    expect(spec.slots[1].isFull('123'), isFalse);
  });

  test('generator fills every slot within its field', () {
    final Random rnd = Random(1);
    for (final PlateSpec spec in <PlateSpec>[
      IndonesiaPlates.car,
      IndonesiaPlates.motorcycleEv,
    ]) {
      for (int n = 0; n < 50; n++) {
        final List<String?> v = IndonesiaSerialGenerator.generate(
          spec,
          random: rnd,
        );
        expect(v, everyElement(isNotNull));
        for (int i = 0; i < v.length; i++) {
          expect(spec.slots[i].accepts(v[i]!), isTrue, reason: '$v at $i');
          expect(spec.slots[i].isComplete(v[i]), isTrue);
        }
        expect(
          IndonesiaValidator()
              .validate(PlateEntry(spec: spec, values: v))
              .isValid,
          isTrue,
          reason: '$v',
        );
      }
    }
  });
}
