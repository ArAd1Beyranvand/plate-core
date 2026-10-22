import 'package:plate_core/plate_core.dart';

import 'malawi_colors.dart';

abstract final class MalawiThemes {
  /// Silver embossed characters on black. The photo shows no frame line, so the
  /// border is a thin 0.02 of the height; neither it nor the corner radius is
  /// measured.
  static final PlateTheme private = PlateTheme.monochrome(
    field: MalawiColors.black,
    ink: MalawiColors.silver,
    inactive: MalawiColors.inactive,
    borderWidthRatio: 0.02,
    plateRadiusRatio: 0.04,
  );
}
