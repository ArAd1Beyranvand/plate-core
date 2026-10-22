import 'package:flutter/widgets.dart';
import 'package:plate_core/plate_core.dart';

import 'bonaire_colors.dart';

/// One ink on one field. Only the navy plate shows a frame line; border and
/// corner ratios are not measured.
abstract final class BonaireThemes {
  static final PlateTheme bonaire = _ink(BonaireColors.white, BonaireColors.black, border: 0);

  static final PlateTheme blue = _ink(BonaireColors.navy, BonaireColors.cream, border: 0.03);

  static final PlateTheme statia = _ink(
    BonaireColors.statiaBlue,
    BonaireColors.statiaInk,
    border: 0,
  );

  static final PlateTheme saba = _ink(BonaireColors.sabaGreen, BonaireColors.sabaInk, border: 0);
}

PlateTheme _ink(Color field, Color ink, {required double border}) => PlateTheme.monochrome(
  field: field,
  ink: ink,
  inactive: BonaireColors.inactive,
  borderWidthRatio: border,
  plateRadiusRatio: 0.05,
);
