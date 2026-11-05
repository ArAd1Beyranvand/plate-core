import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mali_plate/mali_plate.dart';
import 'package:plate_core/plate_core.dart';
import 'package:plate_core/testing.dart';

void main() {
  testWidgets('standard', (tester) async {
    final spec = MaliPlates.all['standard']!();
    final controller = PlateController.fromValues(spec, ['AB', '1234', 'MD']);
    await pumpPlateGolden(
      tester,
      controller,
      'goldens/ml_standard.png',
      theme: MaliThemes.standard,
      scoped: false,
      country: MaliCountry.mali,
      stage: Size(780, 780 * spec.canvasHeight / spec.canvasWidth),
    );
  });
}
