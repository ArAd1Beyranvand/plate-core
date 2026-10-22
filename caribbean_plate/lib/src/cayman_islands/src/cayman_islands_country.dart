import 'package:plate_core/plate_core.dart';

import 'cayman_islands_colors.dart';

/// No Caymanian plate prints a flag or a country block, so every spec sets
/// `noPanel`. The national flag (a blue ensign with the coat of arms) is
/// left out: the arms are a crest, which is not drawn in code, and no plate
/// shows it.
abstract final class CaymanIslandsCountry {
  static const PlateCountry cayman_islands = PlateCountry(
    code: 'ky',
    captionLines: <String>[],
    panelColor: CaymanIslandsColors.blue,
    panelTextColor: CaymanIslandsColors.white,
  );
}
