import 'package:plate_core/plate_core.dart';

import 'bermuda_colors.dart';

/// Black on white, every current plate. The artwork shows no frame line, so
/// the border is a thin 0.02 of the height and the corners round at 0.04;
/// neither is measured.
abstract final class BermudaThemes {
  static final PlateTheme plate = PlateTheme.monochrome(
    field: BermudaColors.white,
    ink: BermudaColors.black,
    inactive: BermudaColors.inactive,
    borderWidthRatio: 0.02,
    plateRadiusRatio: 0.04,
  );
}
