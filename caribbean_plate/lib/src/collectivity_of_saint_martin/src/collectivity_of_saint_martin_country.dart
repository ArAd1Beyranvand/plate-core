import 'package:plate_core/plate_core.dart';

import 'collectivity_of_saint_martin_colors.dart';

/// Saint Martin as a `PlateCountry`: the EU band, as on French plates. The `F`
/// beneath the stars is a label on the spec, so [captionLines] is empty.
abstract final class CollectivityOfSaintMartinCountry {
  static const PlateCountry collectivityOfSaintMartin = PlateCountry(
    code: 'mf',
    captionLines: <String>[],
    panelColor: CollectivityOfSaintMartinColors.euroBlue,
    panelTextColor: CollectivityOfSaintMartinColors.white,
    flagAspectRatio: 40 / 61.2,
    flag: EuropeanStars.band,
  );
}
