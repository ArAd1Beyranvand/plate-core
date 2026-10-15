import 'package:plate_core/plate_core.dart';

import 'zimbabwe_colors.dart';

/// Zimbabwe as a `PlateCountry`. The plate carries no country block, so every
/// spec sets `noPanel`.
abstract final class ZimbabweCountry {
  static const PlateCountry zimbabwe = PlateCountry(
    code: 'zw',
    captionLines: <String>[],
    panelColor: ZimbabweColors.white,
    panelTextColor: ZimbabweColors.black,
  );
}
