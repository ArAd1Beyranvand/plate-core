import 'package:plate_core/plate_core.dart';

import 'collectivity_of_saint_martin_colors.dart';

/// Black on white, framed in the ink. Frame 2.5 of 110 thick (0.0227) as on
/// French plates; the radius is estimated, not measured.
abstract final class CollectivityOfSaintMartinThemes {
  static final PlateTheme private = PlateTheme.monochrome(
    field: CollectivityOfSaintMartinColors.white,
    ink: CollectivityOfSaintMartinColors.black,
    inactive: CollectivityOfSaintMartinColors.inactive,
    borderWidthRatio: 0.0227,
    plateRadiusRatio: 0.055,
  );
}
