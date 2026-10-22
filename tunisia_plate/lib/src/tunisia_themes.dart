import 'package:flutter/widgets.dart';
import 'package:plate_core/plate_core.dart';

import 'tunisia_colors.dart';

/// One ink on one field, a rim in silver or the ink. Ratios are of the canvas
/// height, measured off photos normalised to 520x110: the rim is ~4.5 mm
/// everywhere, the outer corner ~5 mm on pressed plates and ~10 mm on the
/// military one. Dashes are `PlateRule`s, so [PlateTheme.dividerColor] is the
/// ink.
abstract final class TunisiaThemes {
  static PlateTheme _livery({
    required Color field,
    required Color ink,
    required Color inactive,
    Color? rim,
    double plateRadiusRatio = 0.045,
  }) => PlateTheme(
    plateBackground: field,
    plateBorder: rim ?? ink,
    ink: ink,
    dividerColor: ink,
    borderWidthRatio: 0.041,
    plateRadiusRatio: plateRadiusRatio,
    activeColor: ink,
    inactiveColor: inactive,
    alertColor: const Color(0xFFD32F2F),
  );

  /// Also the temporary plate, which the photo shows in the same paint.
  static final PlateTheme standard = _livery(
    field: TunisiaColors.black,
    ink: TunisiaColors.white,
    inactive: TunisiaColors.inactiveOnDark,
    rim: TunisiaColors.rimSilver,
  );

  static final PlateTheme rental = _livery(
    field: TunisiaColors.rentalBlue,
    ink: TunisiaColors.white,
    inactive: TunisiaColors.inactiveOnDark,
    rim: TunisiaColors.rimSilver,
  );

  static final PlateTheme government = _livery(
    field: TunisiaColors.governmentWhite,
    ink: TunisiaColors.governmentRed,
    inactive: TunisiaColors.inactiveOnLight,
  );

  static final PlateTheme diplomatic = _livery(
    field: TunisiaColors.diplomaticWhite,
    ink: TunisiaColors.diplomaticBlack,
    inactive: TunisiaColors.inactiveOnLight,
  );

  /// Rounder corners.
  static final PlateTheme military = _livery(
    field: TunisiaColors.black,
    ink: TunisiaColors.white,
    inactive: TunisiaColors.inactiveOnDark,
    plateRadiusRatio: 0.09,
  );
}
