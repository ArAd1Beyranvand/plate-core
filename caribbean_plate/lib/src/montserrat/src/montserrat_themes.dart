import 'package:plate_core/plate_core.dart';

import 'montserrat_colors.dart';

/// White ink on a near-black field, the frame in the ink.
///
/// The photo shows a raised rim rather than a printed line; the border ratio
/// and corner radius are not measured.
abstract final class MontserratThemes {
  static final PlateTheme private = PlateTheme.monochrome(
    field: MontserratColors.black,
    ink: MontserratColors.white,
    inactive: MontserratColors.inactive,
    borderWidthRatio: 0.02,
    plateRadiusRatio: 0.06,
  );
}
