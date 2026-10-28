import 'package:plate_core/plate_core.dart';

import 'bolivia_colors.dart';

/// Bolivia as a `PlateCountry`. The state flag (with coat of arms) is printed
/// by the PTA plate's panel; the special and Mercosur plates print plain
/// bands and set `noPanel`.
abstract final class BoliviaCountry {
  static const PlateCountry bolivia = PlateCountry(
    code: 'bo',
    captionLines: <String>[],
    panelColor: BoliviaColors.flagGreen,
    panelTextColor: BoliviaColors.white,
    flagAspectRatio: 22 / 15,
    flag: SvgPlateAsset(
      'assets/flags/Flag_of_Bolivia_state.svg',
      package: 'bolivia_plate',
    ),
  );
}
