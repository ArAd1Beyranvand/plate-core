import 'package:plate_core/plate_core.dart';

import 'turks_and_caicos_islands_colors.dart';

/// Turks and Caicos Islands as a `PlateCountry`. The plate has no country
/// block (the name is a printed label), so every spec sets `noPanel`.
abstract final class TurksAndCaicosIslandsCountry {
  static const PlateCountry turks_and_caicos_islands = PlateCountry(
    code: 'tc',
    captionLines: <String>[],
    panelColor: TurksAndCaicosIslandsColors.white,
    panelTextColor: TurksAndCaicosIslandsColors.black,
  );
}
