import 'package:plate_core/plate_core.dart';

import 'riyadh_colors.dart';

/// Black on white for every category; the strip colour belongs to
/// `RiyadhCountry`. The frame width is measured, the corner radius is not.
abstract final class RiyadhThemes {
  static const PlateTheme standard = PlateTheme.monochrome(
    field: RiyadhColors.white,
    ink: RiyadhColors.ink,
    inactive: RiyadhColors.inactive,
    borderWidthRatio: 0.041,
    plateRadiusRatio: 0.08,
  );
}
