import 'package:plate_core/plate_core.dart';

import 'eritrea_colors.dart';

/// Eritrea as a `PlateCountry`. The plate prints no flag or name, only the
/// code `ER` as a label, so the spec sets `noPanel`; this is for hosts that
/// list countries.
abstract final class EritreaCountry {
  static const PlateCountry eritrea = PlateCountry(
    code: 'er',
    captionLines: <String>[],
    panelColor: EritreaColors.flagBlue,
    panelTextColor: EritreaColors.white,
  );
}
