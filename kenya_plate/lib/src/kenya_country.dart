import 'package:flutter/widgets.dart';
import 'package:plate_core/plate_core.dart';

import 'kenya_colors.dart';

/// Kenya as a `PlateCountry`. The plate has no country block, only a small
/// flag decal, so every spec sets `noPanel`.
abstract final class KenyaCountry {
  /// The flag, 900×600: black, red and green stripes with white fimbriation,
  /// and a Maasai shield with two crossed spears. The shield is simplified to
  /// nested polygons and the stripe heights are approximate, not read off the
  /// construction sheet.
  static const PlateDrawing flag = PlateDrawing(900, 600, <PlateShape>[
    PlateRectShape(0, 0, 900, 600, KenyaColors.flagWhite),
    PlateRectShape(0, 0, 900, 165, KenyaColors.flagBlack),
    PlateRectShape(0, 200, 900, 200, KenyaColors.flagRed),
    PlateRectShape(0, 435, 900, 165, KenyaColors.flagGreen),
    PlatePolygonShape(<Offset>[
      Offset(450, 105),
      Offset(535, 150),
      Offset(560, 300),
      Offset(535, 450),
      Offset(450, 495),
      Offset(365, 450),
      Offset(340, 300),
      Offset(365, 150),
    ], KenyaColors.flagBlack),
    PlatePolygonShape(<Offset>[
      Offset(450, 150),
      Offset(505, 180),
      Offset(520, 300),
      Offset(505, 420),
      Offset(450, 450),
      Offset(395, 420),
      Offset(380, 300),
      Offset(395, 180),
    ], KenyaColors.flagRed),
    PlatePolygonShape(<Offset>[
      Offset(300, 120),
      Offset(310, 110),
      Offset(600, 480),
      Offset(590, 490),
    ], KenyaColors.flagWhite),
    PlatePolygonShape(<Offset>[
      Offset(600, 120),
      Offset(590, 110),
      Offset(300, 480),
      Offset(310, 490),
    ], KenyaColors.flagWhite),
  ]);

  static const PlateCountry kenya = PlateCountry(
    code: 'ke',
    captionLines: <String>[],
    panelColor: KenyaColors.white,
    panelTextColor: KenyaColors.black,
    flagAspectRatio: 3 / 2,
    flag: flag,
  );
}
