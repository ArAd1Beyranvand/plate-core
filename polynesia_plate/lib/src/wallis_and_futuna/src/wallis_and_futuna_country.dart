import 'package:plate_core/plate_core.dart';

import 'wallis_and_futuna_colors.dart';

/// Wallis and Futuna as a `PlateCountry`: the EU band, whose stars are
/// `EuropeanStars.band`. The territory's own flag is not printed on the plate.
/// The `F` beneath the stars is a label on the spec.
abstract final class WallisAndFutunaCountry {
  static const PlateCountry wallis_and_futuna = PlateCountry(
    code: 'wf',
    captionLines: <String>[],
    panelColor: WallisAndFutunaColors.euroBlue,
    panelTextColor: WallisAndFutunaColors.white,
    flagAspectRatio: 46 / 70.4,
    flag: EuropeanStars.band,
  );
}
