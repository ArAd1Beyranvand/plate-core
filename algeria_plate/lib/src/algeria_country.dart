import 'package:flutter/widgets.dart';
import 'package:plate_core/plate_core.dart';

import 'algeria_colors.dart';

/// Algeria as a `PlateCountry`. No Algerian plate prints a country block —
/// the army plate's flag is a round decal on the spec — so every spec sets
/// `noPanel` and this carries only the flag for hosts that list countries.
abstract final class AlgeriaCountry {
  static const PlateDrawing _flag = PlateDrawing(900, 600, <PlateShape>[
    PlateRectShape(0, 0, 900, 600, Color(0xFFFFFFFF)),
    PlateRectShape(0, 0, 450, 600, Color(0xFF006633)),
    PlateCrescentShape(450, 300, 150, 36.229, 120, Color(0xFFD21034)),
    PlateStarShape(510.676, 300, 75, Color(0xFFD21034), rotation: 90),
  ]);

  static const PlateCountry algeria = PlateCountry(
    code: 'dz',
    captionLines: <String>[],
    panelColor: AlgeriaColors.flagGreen,
    panelTextColor: AlgeriaColors.white,
    flagAspectRatio: 3 / 2,
    flag: _flag,
  );
}
