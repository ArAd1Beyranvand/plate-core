import 'package:flutter/widgets.dart';
import 'package:plate_core/plate_core.dart';

import 'christmas_island_colors.dart';

/// The two liveries: one ink on one field, framed in the ink.
///
/// The graphic's rim is 1.5 units of 134 (zones at y 0–1.5 and 128–129.5 of
/// the flattened artwork). The issued plate's rim and corner are not
/// measured — `// CALIBRATE`.
abstract final class ChristmasIslandThemes {
  static PlateTheme _field({
    required Color field,
    required Color ink,
    required Color inactive,
    required double borderWidthRatio,
  }) => PlateTheme(
    plateBackground: field,
    plateBorder: ink,
    ink: ink,
    dividerColor: ink,
    borderWidthRatio: borderWidthRatio,
    plateRadiusRatio: 0.067,
    activeColor: ink,
    inactiveColor: inactive,
    alertColor: const Color(0xFFD32F2F),
  );

  /// Black on white: the graphic plate.
  static final PlateTheme standard = _field(
    field: ChristmasIslandColors.white,
    ink: ChristmasIslandColors.black,
    inactive: ChristmasIslandColors.inactiveOnLight,
    borderWidthRatio: 0.011,
  );

  /// Navy on yellow: the issued plate.
  static final PlateTheme yellow = _field(
    field: ChristmasIslandColors.yellow,
    ink: ChristmasIslandColors.navy,
    inactive: ChristmasIslandColors.inactiveOnYellow,
    borderWidthRatio: 0.03,
  );
}
