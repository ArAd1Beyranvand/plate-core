import 'package:plate_core/plate_core.dart';

import 'italy_colors.dart';

/// Italy as a `PlateCountry`: the EU band, whose stars are the shared asset
/// `plate_core` ships. The `I` beneath them is a [PlateLabel] on
/// the spec, so [captionLines] is empty.
abstract final class ItalyCountry {
  static const PlateCountry italy = PlateCountry(
    code: 'it',
    captionLines: <String>[],
    panelColor: ItalyColors.euroBlue,
    panelTextColor: ItalyColors.white,
    flagAspectRatio: 46 / 70.4,
    flag: SvgPlateAsset(
      'assets/flags/Flag_of_Europe.svg',
      package: 'plate_core',
    ),
  );
}
