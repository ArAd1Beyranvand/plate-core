import 'package:flutter/widgets.dart';
import 'package:plate_core/plate_core.dart';

import 'senegal_colors.dart';

/// One ink on one field, the frame in the ink colour.
///
/// The old plate's white frame and the current plate's black one measure
/// ~4 of 110 units (0.04) on the one-row plates; the taller truck and
/// motorcycle plates measure ~5.8 of 325 and 281 (0.02).
abstract final class SenegalThemes {
  /// 1989–2019: white on blue.
  static final PlateTheme old = _ink(
    SenegalColors.blue,
    SenegalColors.white,
    frame: 0.04,
    radius: 0.06,
  );

  /// Current front plate: black on white.
  static final PlateTheme current = _ink(
    SenegalColors.plateWhite,
    SenegalColors.black,
    frame: 0.04,
    radius: 0.09,
  );

  /// Current two-row plates (truck rear, motorcycle).
  static final PlateTheme twoRow = _ink(
    SenegalColors.plateWhite,
    SenegalColors.black,
    frame: 0.02,
    radius: 0.04,
  );
}

PlateTheme _ink(
  Color field,
  Color ink, {
  required double frame,
  required double radius,
}) => PlateTheme.monochrome(
  field: field,
  ink: ink,
  inactive: SenegalColors.inactive,
  borderWidthRatio: frame,
  plateRadiusRatio: radius,
);
