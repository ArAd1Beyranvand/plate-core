import 'package:plate_core/plate_core.dart';

import 'malawi_colors.dart';

/// Malawi as a `PlateCountry`. The plate carries no country block, so the spec
/// sets `noPanel`.
abstract final class MalawiCountry {
  static const PlateCountry malawi = PlateCountry(
    code: 'mw',
    captionLines: <String>[],
    panelColor: MalawiColors.black,
    panelTextColor: MalawiColors.silver,
  );
}
