import 'package:plate_core/plate_core.dart';

import 'sudan_colors.dart';

/// No flag is printed; the names are labels, so every spec sets `noPanel`.
abstract final class SudanCountry {
  static const PlateCountry sudan = PlateCountry(
    code: 'sd',
    captionLines: <String>[],
    panelColor: SudanColors.hologram,
    panelTextColor: SudanColors.privateBlack,
  );
}
