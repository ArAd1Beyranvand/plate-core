import 'package:plate_core/plate_core.dart';

import 'cook_islands_colors.dart';

/// The Cook Islands as a `PlateCountry`. The plates carry no country block
/// (the name is a caption on the face), so every spec sets `noPanel`.
abstract final class CookIslandsCountry {
  // ignore: constant_identifier_names
  static const PlateCountry cook_islands = PlateCountry(
    code: 'ck',
    captionLines: <String>[],
    panelColor: CookIslandsColors.yellow,
    panelTextColor: CookIslandsColors.green,
  );
}
