import 'package:plate_core/plate_core.dart';

import 'sint_maarten_colors.dart';

/// Black ink on the beach-picture field. The photo shows no frame line;
/// border and corner ratios are not measured.
abstract final class SintMaartenThemes {
  static final PlateTheme private = PlateTheme.monochrome(
    field: SintMaartenColors.field,
    ink: SintMaartenColors.black,
    inactive: SintMaartenColors.inactive,
    borderWidthRatio: 0,
    plateRadiusRatio: 0.05,
  );
}
