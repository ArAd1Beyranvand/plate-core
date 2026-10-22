import 'package:flutter/widgets.dart';
import 'package:plate_core/plate_core.dart';

import 'senegal_colors.dart';

/// Senegal as a `PlateCountry`: the blue strip of the current plates, the
/// flag over `SN`. The 1989–2019 plates print no strip and set `noPanel`.
abstract final class SenegalCountry {
  static const PlateDrawing _flag = PlateDrawing(900, 600, <PlateShape>[
    PlateRectShape(0, 0, 900, 600, Color(0xFFE31B23)),
    PlateRectShape(0, 0, 600, 600, Color(0xFFFDEF42)),
    PlateRectShape(0, 0, 300, 600, Color(0xFF00853F)),
    PlateStarShape(450, 300, 100, Color(0xFF00853F)),
  ]);

  static const PlateCountry senegal = PlateCountry(
    code: 'sn',
    captionLines: <String>['SN'],
    panelColor: SenegalColors.blue,
    panelTextColor: SenegalColors.white,
    flagAspectRatio: 3 / 2,
    // https://commons.wikimedia.org/wiki/File:Flag_of_Senegal.svg
    flag: _flag,
  );
}
