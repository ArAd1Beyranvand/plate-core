import 'package:plate_core/plate_core.dart';

import 'norfolk_island_colors.dart';

/// Norfolk Island as a `PlateCountry`. The plate prints no flag or country
/// block (only the caption "N·I"), so the spec sets `noPanel`. The island's
/// flag carries a Norfolk pine and is not drawn.
abstract final class NorfolkIslandCountry {
  static const PlateCountry norfolk_island = PlateCountry(
    code: 'nf',
    captionLines: <String>[],
    panelColor: NorfolkIslandColors.yellow,
    panelTextColor: NorfolkIslandColors.black,
  );
}
