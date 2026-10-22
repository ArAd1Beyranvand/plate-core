import 'package:plate_core/plate_core.dart';

import 'liberia_colors.dart';

/// Liberia as a `PlateCountry`. The plate has no country block (the flag and
/// name are free-standing on the face), so every spec sets `noPanel`.
///
/// The flag is eleven stripes with a square canton five stripes tall, drawn in
/// code at 19:10; no asset.
abstract final class LiberiaCountry {
  static const PlateDrawing flag = PlateDrawing(190, 100, <PlateShape>[
    PlateRectShape(0, 0, 190, 100, LiberiaColors.flagWhite),
    PlateRectShape(0, 0, 190, 100 / 11, LiberiaColors.flagRed),
    PlateRectShape(0, 200 / 11, 190, 100 / 11, LiberiaColors.flagRed),
    PlateRectShape(0, 400 / 11, 190, 100 / 11, LiberiaColors.flagRed),
    PlateRectShape(0, 600 / 11, 190, 100 / 11, LiberiaColors.flagRed),
    PlateRectShape(0, 800 / 11, 190, 100 / 11, LiberiaColors.flagRed),
    PlateRectShape(0, 1000 / 11, 190, 100 / 11, LiberiaColors.flagRed),
    PlateRectShape(0, 0, 500 / 11, 500 / 11, LiberiaColors.flagBlue),
    PlateStarShape(250 / 11, 250 / 11, 16, LiberiaColors.flagWhite),
  ]);

  static const PlateCountry liberia = PlateCountry(
    code: 'lr',
    captionLines: <String>[],
    panelColor: LiberiaColors.field,
    panelTextColor: LiberiaColors.ink,
    flagAspectRatio: 19 / 10,
    flag: flag,
  );
}
