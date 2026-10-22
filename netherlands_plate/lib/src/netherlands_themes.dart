import 'package:flutter/widgets.dart';
import 'package:plate_core/plate_core.dart';

import 'netherlands_colors.dart';

/// One ink on one field, frame in the ink colour.
abstract final class NetherlandsThemes {
  /// Black on reflective yellow: every ordinary and special plate.
  static final PlateTheme standard = _theme(NetherlandsColors.yellow, NetherlandsColors.black);

  /// Dealer ("handelaar") plates: dark on green.
  static final PlateTheme dealer = _theme(
    NetherlandsColors.dealerGreen,
    NetherlandsColors.dealerInk,
  );

  /// BFG (British Forces Germany) plates: light on dark grey.
  static final PlateTheme bfg = _theme(NetherlandsColors.bfgField, NetherlandsColors.bfgInk);
}

PlateTheme _theme(Color field, Color ink) => PlateTheme.monochrome(
  field: field,
  ink: ink,
  inactive: NetherlandsColors.inactive,
  borderWidthRatio: 0.012,
  plateRadiusRatio: 0.04,
);
