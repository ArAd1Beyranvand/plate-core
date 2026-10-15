import 'package:plate_core/plate_core.dart';

import 'netherlands_colors.dart';

/// The Netherlands as a `PlateCountry`: the EU panel (circle-of-stars flag
/// over `NL`) down the left edge of every plate that carries one.
///
/// The flag is `Flag_of_Europe.svg` (Wikimedia Commons).
abstract final class NetherlandsCountry {
  static const PlateCountry netherlands = PlateCountry(
    code: 'nl',
    captionLines: <String>['NL'],
    panelColor: NetherlandsColors.euBlue,
    panelTextColor: NetherlandsColors.euInk,
    flagAspectRatio: 3 / 2,
    flag: SvgPlateAsset(
      'assets/flags/Flag_of_Europe.svg',
      package: 'netherlands_plate',
    ),
  );
}
