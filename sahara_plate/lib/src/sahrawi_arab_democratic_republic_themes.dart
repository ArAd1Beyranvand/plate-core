import 'package:flutter/widgets.dart';
import 'package:plate_core/plate_core.dart';

import 'sahrawi_arab_democratic_republic_colors.dart';

/// One ink on one field; the plates print no frame.
abstract final class SahrawiArabDemocraticRepublicThemes {
  /// Private, black on yellow.
  static final PlateTheme private = _theme(
    SahrawiArabDemocraticRepublicColors.yellowField,
    SahrawiArabDemocraticRepublicColors.yellowInk,
  );

  /// Private, black on white.
  static final PlateTheme privateWhite = _theme(
    SahrawiArabDemocraticRepublicColors.whiteField,
    SahrawiArabDemocraticRepublicColors.whiteInk,
  );

  /// Government, black on green.
  static final PlateTheme government = _theme(
    SahrawiArabDemocraticRepublicColors.greenField,
    SahrawiArabDemocraticRepublicColors.greenInk,
  );

  /// Government, black on white.
  static final PlateTheme governmentWhite = privateWhite;

  /// Army, black on white.
  static final PlateTheme army = privateWhite;
}

PlateTheme _theme(Color field, Color ink) => PlateTheme.monochrome(
  field: field,
  ink: ink,
  inactive: SahrawiArabDemocraticRepublicColors.inactive,
  borderWidthRatio: 0,
  plateRadiusRatio: 0.05,
);
