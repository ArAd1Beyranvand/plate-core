import 'package:plate_core/plate_core.dart';

import 'switzerland_colors.dart';

/// Switzerland as a `PlateCountry`. Swiss plates carry no flag or country
/// caption (the shield is a decal), so every spec sets `noPanel`.
abstract final class SwitzerlandCountry {
  static const PlateCountry switzerland = PlateCountry(
    code: 'ch',
    captionLines: <String>[],
    panelColor: SwitzerlandColors.white,
    panelTextColor: SwitzerlandColors.black,
  );
}
