import 'package:plate_core/plate_core.dart';

import 'montserrat_colors.dart';

/// Montserrat as a `PlateCountry`. The plate carries no country block, so the
/// spec sets `noPanel`.
abstract final class MontserratCountry {
  static const PlateCountry montserrat = PlateCountry(
    code: 'ms',
    captionLines: <String>[],
    panelColor: MontserratColors.black,
    panelTextColor: MontserratColors.white,
  );
}
