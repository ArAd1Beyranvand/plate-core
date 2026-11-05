import 'package:plate_core/plate_core.dart';

import 'indonesia_colors.dart';

/// No current plate prints a country block or flag, so every spec sets
/// `noPanel`.
abstract final class IndonesiaCountry {
  static const PlateCountry indonesia = PlateCountry(
    code: 'id',
    panelColor: IndonesiaColors.governmentRed,
    panelTextColor: IndonesiaColors.white,
    flagAspectRatio: 3 / 2,
  );
}
