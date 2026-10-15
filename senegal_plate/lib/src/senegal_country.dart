import 'package:plate_core/plate_core.dart';

import 'senegal_colors.dart';

/// Senegal as a `PlateCountry`: the blue strip of the current plates, the
/// flag over `SN`. The 1989–2019 plates print no strip and set `noPanel`.
abstract final class SenegalCountry {
  static const PlateCountry senegal = PlateCountry(
    code: 'sn',
    captionLines: <String>['SN'],
    panelColor: SenegalColors.blue,
    panelTextColor: SenegalColors.white,
    flagAspectRatio: 3 / 2,
    // https://commons.wikimedia.org/wiki/File:Flag_of_Senegal.svg
    flag: SvgPlateAsset(
      'assets/flags/Flag_of_Senegal.svg',
      package: 'senegal_plate',
    ),
  );
}
