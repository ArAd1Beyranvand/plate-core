import 'package:flutter/widgets.dart';
import 'package:plate_core/plate_core.dart';

import 'sahrawi_arab_democratic_republic_colors.dart';

/// The flag, shared with the army plate's badge.
const PlateDrawing sahrawiFlagDrawing = PlateDrawing(900, 450, <PlateShape>[
  PlateRectShape(0, 0, 900, 150, SahrawiArabDemocraticRepublicColors.flagBlack),
  PlateRectShape(0, 150, 900, 150, SahrawiArabDemocraticRepublicColors.flagWhite),
  PlateRectShape(0, 300, 900, 150, SahrawiArabDemocraticRepublicColors.flagGreen),
  PlatePolygonShape(<Offset>[
    Offset(0, 0),
    Offset(300, 225),
    Offset(0, 450),
  ], SahrawiArabDemocraticRepublicColors.flagRed),
  PlateCrescentShape(450, 225, 70, 24, 58, SahrawiArabDemocraticRepublicColors.flagRed),
  PlateStarShape(492, 225, 32, SahrawiArabDemocraticRepublicColors.flagRed, rotation: 90),
]);

/// The plates print no country block, so every spec sets `noPanel`.
abstract final class SahrawiArabDemocraticRepublicCountry {
  static const PlateCountry sahrawi_arab_democratic_republic = PlateCountry(
    code: 'eh',
    captionLines: <String>[],
    panelColor: SahrawiArabDemocraticRepublicColors.flagGreen,
    panelTextColor: SahrawiArabDemocraticRepublicColors.flagWhite,
    flagAspectRatio: 2,
    flag: sahrawiFlagDrawing,
  );
}
