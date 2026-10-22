import 'package:flutter/widgets.dart';
import 'package:plate_core/plate_core.dart';

import 'anguilla_colors.dart';

/// Black on the blue-and-white gradient. The plate has no rim, so the border
/// ratio is 0; the corner radius is unmeasured (the artwork is square).
abstract final class AnguillaThemes {
  static final PlateTheme standard = PlateTheme(
    plateBackground: AnguillaColors.white,
    plateBorder: AnguillaColors.black,
    ink: AnguillaColors.black,
    dividerColor: AnguillaColors.black,
    borderWidthRatio: 0,
    plateRadiusRatio: 0.04,
    activeColor: AnguillaColors.black,
    inactiveColor: AnguillaColors.inactive,
    alertColor: const Color(0xFFD32F2F),
  );
}
