import 'package:flutter/widgets.dart' show Color;
import 'package:plate_core/plate_core.dart';

import 'french_polynesia_colors.dart';

/// Black on yellow (front) or white (rear), framed in the ink. The frame is
/// 2.5 of 110 thick (0.0227) as on French plates; the radius is estimated,
/// not measured.
abstract final class FrenchPolynesiaThemes {
  static final PlateTheme front = _theme(FrenchPolynesiaColors.yellow);
  static final PlateTheme rear = _theme(FrenchPolynesiaColors.white);

  static PlateTheme _theme(Color field) => PlateTheme.monochrome(
    field: field,
    ink: FrenchPolynesiaColors.black,
    inactive: FrenchPolynesiaColors.inactive,
    borderWidthRatio: 0.0227,
    plateRadiusRatio: 0.055,
  );
}
