import 'package:plate_core/plate_core.dart';

import 'saba_island_colors.dart';

/// One ink on one field. The 1978 plate has a thin teal rim (about 2% of the
/// height, read off the flattened photo); the 2011 plate shows none.
abstract final class SabaIslandThemes {
  static const PlateTheme current = PlateTheme.monochrome(
    field: SabaIslandColors.green,
    ink: SabaIslandColors.white,
    inactive: SabaIslandColors.inactive,
    borderWidthRatio: 0,
    plateRadiusRatio: 0.05,
  );

  static const PlateTheme classic1978 = PlateTheme.monochrome(
    field: SabaIslandColors.cream,
    ink: SabaIslandColors.teal,
    inactive: SabaIslandColors.inactive,
    borderWidthRatio: 0.02,
    plateRadiusRatio: 0.05,
  );
}
