import 'package:flutter/widgets.dart';
import 'package:plate_core/plate_core.dart';

/// Mali plates have no country block or flag panel.
abstract final class MaliCountry {
  static const Color _transparent = Color(0x00000000);

  static const PlateCountry mali = PlateCountry(
    code: 'ml',
    captionLines: <String>[],
    panelColor: _transparent,
    panelTextColor: _transparent,
    flagAspectRatio: 2,
  );
}
