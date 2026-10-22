import 'package:flutter/widgets.dart';
import 'package:plate_core/plate_core.dart';

import 'cayman_islands_colors.dart';

/// The liveries: one ink on one field inside a black rim.
///
/// The rim is ~1.5 of the 71-unit reference height, 0.02 of the plate height.
abstract final class CaymanIslandsThemes {
  static PlateTheme _field({required Color field, required Color ink, required Color inactive}) =>
      PlateTheme(
        plateBackground: field,
        plateBorder: CaymanIslandsColors.black,
        ink: ink,
        dividerColor: ink,
        borderWidthRatio: 0.02,
        plateRadiusRatio: 0.065,
        activeColor: ink,
        inactiveColor: inactive,
        alertColor: const Color(0xFFD32F2F),
      );

  /// Black on yellow: private cars, both the 3+3 and the five-digit plate.
  static final PlateTheme private = _field(
    field: CaymanIslandsColors.yellow,
    ink: CaymanIslandsColors.black,
    inactive: CaymanIslandsColors.inactiveOnLight,
  );

  /// Red on yellow: disabled drivers. Not in any image; the red is the taxi's.
  static final PlateTheme disabled = _field(
    field: CaymanIslandsColors.yellow,
    ink: CaymanIslandsColors.red,
    inactive: CaymanIslandsColors.inactiveOnLight,
  );

  /// Black on orange: heavy goods vehicles and trailers.
  static final PlateTheme heavy = _field(
    field: CaymanIslandsColors.orange,
    ink: CaymanIslandsColors.orangeInk,
    inactive: CaymanIslandsColors.inactiveOnLight,
  );

  /// Red on white: taxis. The caption is blue, set on the label.
  static final PlateTheme taxi = _field(
    field: CaymanIslandsColors.white,
    ink: CaymanIslandsColors.red,
    inactive: CaymanIslandsColors.inactiveOnLight,
  );

  /// Black on white: hire cars.
  static final PlateTheme hire = _field(
    field: CaymanIslandsColors.white,
    ink: CaymanIslandsColors.hireInk,
    inactive: CaymanIslandsColors.inactiveOnLight,
  );
}
