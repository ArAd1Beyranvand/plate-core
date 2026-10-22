import 'package:plate_core/plate_core.dart';

import 'christmas_island_colors.dart';

/// Christmas Island as a `PlateCountry`. No plate prints a flag or country
/// block (the issued plate names the island in a caption), so every spec sets
/// `noPanel`. The real flag carries a coat-of-arms emblem, so none is drawn.
abstract final class ChristmasIslandCountry {
  static const PlateCountry christmas_island = PlateCountry(
    code: 'cx',
    captionLines: <String>[],
    panelColor: ChristmasIslandColors.panel,
    panelTextColor: ChristmasIslandColors.white,
  );
}
