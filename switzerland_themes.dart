import 'package:flutter/widgets.dart';
import 'package:plate_core/plate_core.dart';

import 'switzerland_colors.dart';

/// The liveries. Each is one ink on one field with the rim in the ink, so they
/// are one helper and a call each.
///
/// Rim and corner radius are estimated by eye off the flat photographs
/// (about 1% and 4% of the height); the scooter's black rim is visibly
/// thicker.
abstract final class SwitzerlandThemes {
  static PlateTheme _livery({
    required Color field,
    Color ink = SwitzerlandColors.black,
    double border = 0.01,
  }) => PlateTheme(
    plateBackground: field,
    plateBorder: ink,
    ink: ink,
    dividerColor: ink,
    borderWidthRatio: border,
    plateRadiusRatio: 0.04,
    activeColor: ink,
    inactiveColor: SwitzerlandColors.inactive,
    alertColor: const Color(0xFFD32F2F),
  );

  /// Black on white: cars, motorcycles, trailers, dealers, temporary, front.
  static final PlateTheme standard = _livery(field: SwitzerlandColors.white);

  static final PlateTheme utility = _livery(field: SwitzerlandColors.utility);

  static final PlateTheme exceptional = _livery(field: SwitzerlandColors.exceptional);

  static final PlateTheme agricultural = _livery(field: SwitzerlandColors.agricultural);

  static final PlateTheme scooter = _livery(field: SwitzerlandColors.scooter, border: 0.03);

  /// Bicycle-carrier plate: black on red.
  static final PlateTheme red = _livery(field: SwitzerlandColors.red);

  /// White on dark grey.
  static final PlateTheme military = _livery(
    field: SwitzerlandColors.military,
    ink: SwitzerlandColors.white,
  );

  /// Diplomatic and consular plates: the band is on the spec, the face white.
  static final PlateTheme diplomatic = _livery(field: SwitzerlandColors.white);
}
