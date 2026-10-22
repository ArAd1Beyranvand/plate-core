import 'package:flutter/widgets.dart';
import 'package:plate_core/plate_core.dart';

import 'kenya_colors.dart';

/// One ink on one field, the frame in the ink.
///
/// The photos show a thin dark frame inset from a rounded edge; the 0.025 /
/// 0.05 ratios are estimated from them, not measured.
abstract final class KenyaThemes {
  /// Front plate: black on white.
  static final PlateTheme white = _ink(KenyaColors.white, KenyaColors.black);

  /// Rear plate: black on yellow.
  static final PlateTheme yellow = _ink(KenyaColors.yellow, KenyaColors.black);

  /// Electric vehicles and motorcycles: white on green.
  static final PlateTheme electric = _ink(KenyaColors.green, KenyaColors.white);

  /// County government: blue on white.
  static final PlateTheme county = _ink(KenyaColors.white, KenyaColors.blue);

  /// Diplomatic and UN: white on red (field unsampled).
  static final PlateTheme diplomatic = _ink(KenyaColors.red, KenyaColors.white);
}

PlateTheme _ink(Color field, Color ink) => PlateTheme.monochrome(
  field: field,
  ink: ink,
  inactive: KenyaColors.inactive,
  borderWidthRatio: 0.025,
  plateRadiusRatio: 0.05,
);
