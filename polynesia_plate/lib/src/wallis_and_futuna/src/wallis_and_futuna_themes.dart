import 'package:flutter/widgets.dart';
import 'package:plate_core/plate_core.dart';

import 'wallis_and_futuna_colors.dart';

/// Black on white at the front, black on yellow at the rear, framed in the
/// ink. Frame ratio is France's (2.5 of 110); the radius is estimated, not
/// measured.
abstract final class WallisAndFutunaThemes {
  static final PlateTheme front = _framed(WallisAndFutunaColors.white, WallisAndFutunaColors.black);
  static final PlateTheme rear = _framed(
    WallisAndFutunaColors.yellow,
    WallisAndFutunaColors.yellowInk,
  );
}

PlateTheme _framed(Color field, Color ink) => PlateTheme.monochrome(
  field: field,
  ink: ink,
  inactive: WallisAndFutunaColors.inactive,
  borderWidthRatio: 0.0227,
  plateRadiusRatio: 0.055,
);
