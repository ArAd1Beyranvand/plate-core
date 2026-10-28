import 'package:flutter/widgets.dart';
import 'package:plate_core/plate_core.dart';

import 'niger_colors.dart';

/// The panel is the map's own box, so no panel colour shows around it and each
/// aspect ratio is that box's. The private map is a black silhouette, the
/// commercial one is filled with the flag.
abstract final class NigerCountry {
  static const PlateDrawing _flag = PlateDrawing(700, 600, <PlateShape>[
    PlateRectShape(0, 0, 700, 600, Color(0xFF0DB02B)),
    PlateRectShape(0, 0, 700, 400, Color(0xFFFFFFFF)),
    PlateRectShape(0, 0, 700, 200, Color(0xFFE05206)),
    PlateCircleShape(350, 300, 85, Color(0xFFE05206)),
  ]);

  static const PlateCountry private = PlateCountry(
    code: 'ne',
    captionLines: <String>[],
    panelColor: NigerColors.privateWhite,
    panelTextColor: NigerColors.black,
    flagAspectRatio: 45.8 / 37.4,
    flag: SvgPlateAsset('assets/maps/niger_map.svg', package: 'niger_plate'),
  );

  static const PlateCountry commercial = PlateCountry(
    code: 'ne',
    captionLines: <String>[],
    panelColor: NigerColors.commercialOrange,
    panelTextColor: NigerColors.black,
    flagAspectRatio: 52.0 / 39.7,
    flag: SvgPlateAsset(
      'assets/maps/niger_map_flag.svg',
      package: 'niger_plate',
    ),
  );

  static const PlateCountry plain = PlateCountry(
    code: 'ne',
    captionLines: <String>[],
    panelColor: NigerColors.privateWhite,
    panelTextColor: NigerColors.black,
  );

  static const PlateCountry military = PlateCountry(
    code: 'ne',
    captionLines: <String>[],
    panelColor: NigerColors.militaryBlack,
    panelTextColor: NigerColors.militaryWhite,
    flagAspectRatio: 7 / 6,
    flag: _flag,
  );
}
