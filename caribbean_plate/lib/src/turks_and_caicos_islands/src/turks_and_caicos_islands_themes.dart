import 'package:flutter/widgets.dart';
import 'package:plate_core/plate_core.dart';

import 'turks_and_caicos_islands_colors.dart';

/// One ink on a white field (yellow for self-drive), the frame in the ink.
///
/// The photos show no frame line, so the border is a thin 0.02 of the height
/// and the corners round at 0.04; neither is measured.
abstract final class TurksAndCaicosIslandsThemes {
  /// Private plate, 1978 to 2022: red on white.
  static final PlateTheme privateRed = _ink(
    TurksAndCaicosIslandsColors.white,
    TurksAndCaicosIslandsColors.red,
  );

  /// Private plate since December 2022: black on white.
  static final PlateTheme privateBlack = _ink(
    TurksAndCaicosIslandsColors.white,
    TurksAndCaicosIslandsColors.black,
  );

  /// Commercial: green on white.
  static final PlateTheme commercial = _ink(
    TurksAndCaicosIslandsColors.white,
    TurksAndCaicosIslandsColors.green,
  );

  /// Government: black on white.
  static final PlateTheme government = privateBlack;

  /// Self-drive rental: yellow on white.
  static final PlateTheme selfDrive = _ink(
    TurksAndCaicosIslandsColors.white,
    TurksAndCaicosIslandsColors.yellow,
  );
}

PlateTheme _ink(Color field, Color ink) => PlateTheme.monochrome(
  field: field,
  ink: ink,
  inactive: TurksAndCaicosIslandsColors.inactive,
  borderWidthRatio: 0.02,
  plateRadiusRatio: 0.04,
);
