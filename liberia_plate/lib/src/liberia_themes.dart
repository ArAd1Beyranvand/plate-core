import 'package:plate_core/plate_core.dart';

import 'liberia_colors.dart';

/// Black ink on the pale field, the frame in the ink. The photo shows a thin
/// black rim; its width (0.015) and the corner radius (0.05) are not measured.
abstract final class LiberiaThemes {
  static final PlateTheme diplomatic = PlateTheme.monochrome(
    field: LiberiaColors.field,
    ink: LiberiaColors.ink,
    inactive: LiberiaColors.inactive,
    borderWidthRatio: 0.015,
    plateRadiusRatio: 0.05,
  );
}
