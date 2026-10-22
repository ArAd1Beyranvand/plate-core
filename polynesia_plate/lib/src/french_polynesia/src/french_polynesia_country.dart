import 'package:plate_core/plate_core.dart';

import 'french_polynesia_colors.dart';

/// French Polynesia as a `PlateCountry`: the EU band, as on French plates. The
/// `F` beneath the stars is a label on the spec, so [captionLines] is empty.
/// The territory's own flag is not printed on the plate.
abstract final class FrenchPolynesiaCountry {
  static const PlateCountry french_polynesia = PlateCountry(
    code: 'pf',
    captionLines: <String>[],
    panelColor: FrenchPolynesiaColors.euroBlue,
    panelTextColor: FrenchPolynesiaColors.white,
    flagAspectRatio: 46 / 70.4,
    flag: EuropeanStars.band,
  );
}
