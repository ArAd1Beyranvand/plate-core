import 'package:flutter/widgets.dart';
import 'package:plate_core/plate_core.dart';

import 'cook_islands_colors.dart';

/// One ink on one field, the frame in the ink.
///
/// The car artwork's frame is a thin green line inside the yellow edge; its
/// width (0.03 of the height) and corner radius (0.08) are read off the
/// artwork by eye, not measured. The motorcycle photo shows neither.
abstract final class CookIslandsThemes {
  /// Car plate: green on yellow.
  static final PlateTheme car = _ink(CookIslandsColors.yellow, CookIslandsColors.green);

  /// Motorcycle plate: dark on amber.
  static final PlateTheme motorcycle = _ink(CookIslandsColors.amber, CookIslandsColors.amberInk);
}

PlateTheme _ink(Color field, Color ink) => PlateTheme.monochrome(
  field: field,
  ink: ink,
  inactive: CookIslandsColors.inactive,
  borderWidthRatio: 0.03,
  plateRadiusRatio: 0.08,
);
