import 'package:plate_core/plate_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yemen_plate/yemen_plate.dart';

/// Goldens for the two systems. The northern private/government pair is one
/// spec rendered twice with only `country:` and `theme:` differing: the images
/// should differ in field colour and panel word and nothing else. The other
/// goldens pin the min/max fields at both ends of their range.
///
/// Regenerate with `flutter test --update-goldens` after a deliberate change.
void main() {
  Future<void> renderGolden(
    WidgetTester tester, {
    required PlateSpec spec,
    required PlateTheme theme,
    required PlateCountry country,
    required List<String?> values,
    required String name,
  }) async {
    final controller = PlateController.fromValues(spec, values);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 520,
              height: 520 * spec.canvasHeight / spec.canvasWidth,
              child: PlateThemeScope(
                theme: theme,
                child: PlateView(controller: controller, theme: theme, country: country),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(find.byType(PlateView), matchesGoldenFile('goldens/$name.png'));

    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
  }

  final cases = <String, (PlateSpec, PlateTheme, PlateCountry, List<String?>)>{
    'ye_northern_car_private': (
      YemenNorthernPlates.car,
      YemenThemes.forNorthernUsage(YemenUsage.private),
      YemenCountry.northernFor(YemenUsage.private),
      ['12', '34567'],
    ),
    'ye_northern_car_government': (
      YemenNorthernPlates.car,
      YemenThemes.forNorthernUsage(YemenUsage.government),
      YemenCountry.northernFor(YemenUsage.government),
      ['12', '34567'],
    ),
    'ye_northern_car_short': (
      YemenNorthernPlates.car,
      YemenThemes.forNorthernUsage(YemenUsage.private),
      YemenCountry.northernFor(YemenUsage.private),
      ['7', '1234'],
    ),
    'ye_northern_moto': (
      // ignore: deprecated_member_use_from_same_package
      YemenNorthernPlates.moto,
      YemenThemes.forNorthernUsage(YemenUsage.private),
      YemenCountry.northernFor(YemenUsage.private),
      ['12', '345678'],
    ),
    'ye_unified_car': (
      YemenUnifiedPlates.car,
      YemenThemes.forUnifiedUsage(YemenUsage.private),
      YemenCountry.unifiedFor(YemenUsage.private),
      ['243786', '12'],
    ),
    'ye_unified_car_short': (
      YemenUnifiedPlates.car,
      YemenThemes.forUnifiedUsage(YemenUsage.private),
      YemenCountry.unifiedFor(YemenUsage.private),
      ['2437', '12'],
    ),
    'ye_unified_moto': (
      YemenUnifiedPlates.moto,
      YemenThemes.forUnifiedUsage(YemenUsage.private),
      YemenCountry.unifiedFor(YemenUsage.private),
      ['243786', '12'],
    ),
  };

  for (final entry in cases.entries) {
    testWidgets(entry.key, (tester) async {
      final (spec, theme, country, values) = entry.value;
      await renderGolden(
        tester,
        spec: spec,
        theme: theme,
        country: country,
        values: values,
        name: entry.key,
      );
    });
  }
}
