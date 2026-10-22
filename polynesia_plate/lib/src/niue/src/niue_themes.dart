import 'package:plate_core/plate_core.dart';

import 'niue_colors.dart';

/// Black on white, the frame in the ink. The photo's frame is about 3% of the
/// height with corners rounding at about 6%.
abstract final class NiueThemes {
  static final PlateTheme standard = PlateTheme.monochrome(
    field: NiueColors.white,
    ink: NiueColors.black,
    inactive: NiueColors.inactive,
    borderWidthRatio: 0.03,
    plateRadiusRatio: 0.06,
  );
}
