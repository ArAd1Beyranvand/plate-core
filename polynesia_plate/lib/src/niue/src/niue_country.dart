import 'package:plate_core/plate_core.dart';

import 'niue_colors.dart';

/// Niue as a `PlateCountry`. The plate prints no flag or country block; the
/// name "NIUE" is a stacked label on the face.
abstract final class NiueCountry {
  static const PlateCountry niue = PlateCountry(
    code: 'nu',
    captionLines: <String>[],
    panelColor: NiueColors.white,
    panelTextColor: NiueColors.black,
  );
}
