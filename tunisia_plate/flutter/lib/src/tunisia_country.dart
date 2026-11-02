import 'package:flutter/widgets.dart';
import 'package:plate_core/plate_core.dart';

import 'tunisia_colors.dart';

/// No plate prints a country block (the military flag is a decal), so every
/// spec sets `noPanel`; the flag is carried for hosts that list countries.
abstract final class TunisiaCountry {
  static const PlateDrawing _flag = PlateDrawing(120, 80, <PlateShape>[
    PlateRectShape(0, 0, 120, 80, TunisiaColors.flagRed),
    PlateCircleShape(60, 40, 20, Color(0xFFFFFFFF)),
    PlateCrescentShape(60, 40, 15, 4, 12, TunisiaColors.flagRed),
    PlateStarShape(64, 40, 9, TunisiaColors.flagRed, rotation: 270),
  ]);

  static const PlateCountry tunisia = PlateCountry(
    code: 'tn',
    captionLines: <String>[],
    panelColor: TunisiaColors.flagRed,
    panelTextColor: TunisiaColors.white,
    flagAspectRatio: 3 / 2,
    flag: _flag,
  );
}
