import 'package:flutter/widgets.dart';
import 'package:plate_core/plate_core.dart';

import 'zimbabwe_colors.dart';

/// One ink on one field, the frame in the ink.
///
/// The photos show no frame line, so the border is a thin 0.02 of the height
/// and the corners round at 0.04; neither is measured.
abstract final class ZimbabweThemes {
  /// Private single-row plate (2006).
  static final PlateTheme yellow = _ink(ZimbabweColors.yellow, ZimbabweColors.yellowInk);

  /// Private two-row plate.
  static final PlateTheme yellowStacked = _ink(
    ZimbabweColors.yellowStacked,
    ZimbabweColors.stackedInk,
  );

  /// Private plate on the white field introduced in 2006.
  static final PlateTheme white = _ink(ZimbabweColors.white, ZimbabweColors.black);

  /// Commercial plate: red on white.
  static final PlateTheme commercial = _ink(ZimbabweColors.white, ZimbabweColors.red);
}

PlateTheme _ink(Color field, Color ink) => PlateTheme.monochrome(
  field: field,
  ink: ink,
  inactive: ZimbabweColors.inactive,
  borderWidthRatio: 0.02,
  plateRadiusRatio: 0.04,
);
