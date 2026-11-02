import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mali_plate/mali_plate.dart';
import 'package:plate_core/plate_core.dart';

void main() {
  testWidgets('standard', (tester) async {
    final spec = MaliPlates.all['standard']!();
    final controller = PlateController.fromValues(spec, ['AB', '1234', 'MD']);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 780,
              height: 780 * spec.canvasHeight / spec.canvasWidth,
              child: PlateView(
                controller: controller,
                theme: MaliThemes.standard,
                country: MaliCountry.mali,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(PlateView),
      matchesGoldenFile('goldens/ml_standard.png'),
    );
    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
  });
}
