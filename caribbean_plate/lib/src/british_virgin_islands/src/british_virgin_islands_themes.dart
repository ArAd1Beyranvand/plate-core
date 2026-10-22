import 'package:flutter/widgets.dart';

import 'package:plate_core/plate_core.dart';

import 'british_virgin_islands_colors.dart';

/// One ink on one field per category. Commercial and taxi plates print a
/// thin black frame line (photos), private and government do not. Neither
/// the frame width nor the corner radius is measured.
abstract final class BritishVirginIslandsThemes {
  static final PlateTheme private = _theme(
    BritishVirginIslandsColors.yellow,
    BritishVirginIslandsColors.yellowInk,
    framed: false,
  );

  static final PlateTheme government = _theme(
    BritishVirginIslandsColors.red,
    BritishVirginIslandsColors.redInk,
    framed: false,
  );

  static final PlateTheme commercial = _theme(
    BritishVirginIslandsColors.paleBlue,
    BritishVirginIslandsColors.paleBlueInk,
    framed: true,
  );

  static final PlateTheme taxi = _theme(
    BritishVirginIslandsColors.grey,
    BritishVirginIslandsColors.greyInk,
    framed: true,
  );

  static PlateTheme _theme(Color field, Color ink, {required bool framed}) => PlateTheme.monochrome(
    field: field,
    ink: ink,
    inactive: BritishVirginIslandsColors.inactive,
    borderWidthRatio: framed ? 0.03 : 0,
    plateRadiusRatio: 0.05,
  );
}
