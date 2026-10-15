import 'package:flutter/painting.dart' show Color;
import 'package:plate_core/plate_core.dart';

import 'eritrea_colors.dart';

/// Black on white with a thin black rim (about 2% of the height, off the
/// 4..8 unit rim of the flattened photo).
abstract final class EritreaThemes {
  static final PlateTheme standard = PlateTheme(
    plateBackground: EritreaColors.white,
    plateBorder: EritreaColors.ink,
    ink: EritreaColors.ink,
    dividerColor: EritreaColors.ink,
    borderWidthRatio: 0.02,
    plateRadiusRatio: 0.02,
    activeColor: EritreaColors.ink,
    inactiveColor: EritreaColors.inactive,
    alertColor: const Color(0xFFD32F2F),
  );
}
