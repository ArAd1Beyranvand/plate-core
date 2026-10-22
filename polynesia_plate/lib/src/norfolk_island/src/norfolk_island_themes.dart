import 'package:plate_core/plate_core.dart';

import 'norfolk_island_colors.dart';

/// Black on yellow, the frame in the ink. The photo's frame is about 1.5% of
/// the height with corners rounding at about 4%.
abstract final class NorfolkIslandThemes {
  static final PlateTheme private = PlateTheme.monochrome(
    field: NorfolkIslandColors.yellow,
    ink: NorfolkIslandColors.black,
    inactive: NorfolkIslandColors.inactive,
    borderWidthRatio: 0.015,
    plateRadiusRatio: 0.04,
  );
}
