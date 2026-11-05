import 'package:flutter/widgets.dart';
import 'package:plate_core/plate_core.dart';

import 'malaysia_colors.dart';

/// Only the JPJePlate prints a country block (the green strip with the flag);
/// every other plate is plain type and its specs set `noPanel`.
abstract final class MalaysiaCountry {
  static const PlateDrawing _flag = PlateDrawing(28, 14, <PlateShape>[
    PlateRectShape(0, 0, 28, 14, Color(0xFFFFFFFF)),
    PlateRectShape(0, 0, 28, 1, Color(0xFFCC0000)),
    PlateRectShape(0, 2, 28, 1, Color(0xFFCC0000)),
    PlateRectShape(0, 4, 28, 1, Color(0xFFCC0000)),
    PlateRectShape(0, 6, 28, 1, Color(0xFFCC0000)),
    PlateRectShape(0, 8, 28, 1, Color(0xFFCC0000)),
    PlateRectShape(0, 10, 28, 1, Color(0xFFCC0000)),
    PlateRectShape(0, 12, 28, 1, Color(0xFFCC0000)),
    PlateRectShape(0, 0, 14, 8.5, Color(0xFF000066)),
    PlateCrescentShape(8.5815, 4, 2.667, 0.6674, 3, Color(0xFFFFCC00)),
    PlateStarShape(
      8.75,
      4,
      2.5,
      Color(0xFFFFCC00),
      points: 14,
      innerRatio: 0.4,
    ),
  ]);

  static const PlateCountry malaysia = PlateCountry(
    code: 'my',
    // MAL is a label on the JPJePlate spec.
    panelColor: MalaysiaColors.evGreen,
    panelTextColor: MalaysiaColors.darkInk,
    flagAspectRatio: 2,
    flag: _flag,
  );
}
