import 'package:plate_core/plate_core.dart';

import 'british_virgin_islands_colors.dart';

/// The British Virgin Islands as a `PlateCountry`. No plate prints a country
/// block or a flag (the flag on the article page is not on any plate), so
/// every spec sets `noPanel`; the caption is a label on the spec.
abstract final class BritishVirginIslandsCountry {
  static const PlateCountry british_virgin_islands = PlateCountry(
    code: 'vg',
    captionLines: <String>[],
    panelColor: BritishVirginIslandsColors.yellow,
    panelTextColor: BritishVirginIslandsColors.yellowInk,
  );
}
