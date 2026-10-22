import 'package:plate_core/plate_core.dart';

import 'sint_eustatius_colors.dart';

/// Border widths are not measured; the 2007 plate has no frame.
abstract final class SintEustatiusThemes {
  static final PlateTheme statia = PlateTheme.monochrome(
    field: SintEustatiusColors.blue,
    ink: SintEustatiusColors.blueInk,
    inactive: SintEustatiusColors.inactive,
    borderWidthRatio: 0,
    plateRadiusRatio: 0.05,
  );

  /// Maroon ink inside a red frame line.
  static final PlateTheme bicentennial = PlateTheme(
    plateBackground: SintEustatiusColors.white,
    plateBorder: SintEustatiusColors.red,
    ink: SintEustatiusColors.maroon,
    dividerColor: SintEustatiusColors.maroon,
    borderWidthRatio: 0.03,
    plateRadiusRatio: 0.05,
    activeColor: SintEustatiusColors.maroon,
    inactiveColor: SintEustatiusColors.inactive,
  );
}
