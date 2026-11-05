import 'dart:io';

import 'package:plate_core/plate_core.dart';
import 'package:plate_core/testing.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:malaysia_plate/malaysia_plate.dart';

/// One golden per category, drawn with a real bold face so the ink can be
/// measured against the references (see `_Layout` in `malaysia_plates.dart`).
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
    await pumpPlateGolden(
      tester,
      controller,
      'goldens/$name.png',
      theme: theme,
      country: MalaysiaCountry.malaysia,
      stage: Size(520, 520 * spec.canvasHeight / spec.canvasWidth),
    );
  }

  testWidgets('private, QAB 8557 K', (tester) async {
    await render(
      tester,
      spec: MalaysiaPlates.singleRow(suffix: true),
      theme: MalaysiaThemes.standard,
      values: 'QAB 8557 K',
      name: 'my_single_suffix',
    );
  });

  testWidgets('private, PFQ 5217', (tester) async {
    await render(
      tester,
      spec: MalaysiaPlates.singleRow(),
      theme: MalaysiaThemes.standard,
      values: 'PFQ 5217',
      name: 'my_single',
    );
  });

  testWidgets('taxi, HWD 378', (tester) async {
    await render(
      tester,
      spec: MalaysiaPlates.singleRow(),
      theme: MalaysiaThemes.taxi,
      values: 'HWD 378',
      name: 'my_taxi',
    );
  });

  testWidgets('two-row, QAF 6229', (tester) async {
    await render(
      tester,
      spec: MalaysiaPlates.twoRow(),
      theme: MalaysiaThemes.standard,
      values: 'QAF 6229',
      name: 'my_two_row',
    );
  });

  testWidgets('diplomatic, 99-64-DC', (tester) async {
    await render(
      tester,
      spec: MalaysiaPlates.diplomatic,
      theme: MalaysiaThemes.diplomatic,
      values: '99 64 DC',
      name: 'my_diplomatic',
    );
  });

  testWidgets('JPJePlate', (tester) async {
    await render(
      tester,
      spec: MalaysiaPlates.ev(),
      theme: MalaysiaThemes.ev,
      values: 'VEA 1234',
      name: 'my_ev',
    );
  });

  test('validator', () {
    bool ok(String prefix, String number, [String suffix = '']) =>
        MalaysiaValidator.validateFields(
          prefix: prefix,
          number: number,
          suffix: suffix,
        ) ==
        const PlateValidation.valid();
    expect(ok('QAB', '8557', 'K'), isTrue);
    expect(ok('WOA', '1'), isFalse);
    expect(ok('W', '0123'), isFalse);
    expect(ok('SAA', '8967', 'S'), isFalse);
  });
}
