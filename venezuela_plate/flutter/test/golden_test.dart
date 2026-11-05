import 'dart:io';

import 'package:plate_core/plate_core.dart';
import 'package:plate_core/testing.dart';
import 'package:venezuela_plate/venezuela_plate.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// One golden per spec, rendered with a real font so the caption, state name and the
/// serial can be measured against the reference photographs.
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
    String value,
    String name,
  ) async {
    final controller = PlateController.fromValues(spec, <String?>[
      value.substring(0, 6),
      value.substring(6),
    ]);
    await pumpPlateGolden(
      tester,
      controller,
      'goldens/$name.png',
      theme: VenezuelaPlates.theme,
      country: VenezuelaCountry.venezuela,
      stage: Size(520, 520 * spec.canvasHeight / spec.canvasWidth),
    );
  }

  testWidgets(
    'car, Lara',
    (t) => renderGolden(t, VenezuelaPlates.car, 'AB174SK', 've_car_lara'),
  );
  testWidgets(
    'car, Distrito Capital',
    (t) => renderGolden(
      t,
      VenezuelaPlates.car,
      'AA848YA',
      've_car_distrito_capital',
    ),
  );
}
