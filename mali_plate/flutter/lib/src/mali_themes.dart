import 'package:flutter/widgets.dart';
import 'package:plate_core/plate_core.dart';

import 'mali_colors.dart';

/// Black on white.
abstract final class MaliThemes {
  static const double _borderWidthRatio = 0.04;
  static const double _radiusRatio = 0.12;

  static const PlateTheme standard = PlateTheme.monochrome(
    field: MaliColors.white,
    ink: MaliColors.black,
    inactive: Color(0x66666666),
    borderWidthRatio: _borderWidthRatio,
    plateRadiusRatio: _radiusRatio,
  );
}
