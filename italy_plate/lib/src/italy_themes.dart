import 'package:plate_core/plate_core.dart';

import 'italy_colors.dart';

/// Black on white in every design; only the frame scales with the plate.
///
/// The car plate's frame is 2.5 of 110 thick (0.0227), read off the vector
/// reference. The two-line and motorcycle frames keep the same 2.5 units and
/// so are a smaller share of their taller canvases. The corner radii are
/// estimated from the flats (about 6 units), not measured.
abstract final class ItalyThemes {
  static final PlateTheme private = _framed(0.0227, 0.055);
  static final PlateTheme twoLine = _framed(0.0114, 0.027);
  static final PlateTheme motorcycle = _framed(0.014, 0.034);
}

PlateTheme _framed(double border, double radius) => PlateTheme.monochrome(
  field: ItalyColors.white,
  ink: ItalyColors.black,
  inactive: ItalyColors.inactive,
  borderWidthRatio: border,
  plateRadiusRatio: radius,
);
