import 'package:plate_core/plate_core.dart';

import 'anguilla_colors.dart';

/// Anguilla as a `PlateCountry`. The plate prints no country block — the
/// coat of arms is a decal on the spec — so the spec sets `noPanel` and
/// `panelColor` is the gradient's blue, which the background paints.
///
/// The flag (a blue ensign carrying the coat of arms) is an SVG: the arms are
/// an emblem, not shapes an algorithm draws.
/// Source: https://commons.wikimedia.org/wiki/File:Flag_of_Anguilla.svg
abstract final class AnguillaCountry {
  static const PlateCountry anguilla = PlateCountry(
    code: 'ai',
    captionLines: <String>[],
    panelColor: AnguillaColors.sky,
    panelTextColor: AnguillaColors.black,
    flagAspectRatio: 2,
    flag: SvgPlateAsset('assets/anguilla/flags/Flag_of_Anguilla.svg', package: 'caribbean_plate'),
  );
}
