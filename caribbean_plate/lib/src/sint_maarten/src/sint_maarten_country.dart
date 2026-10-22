import 'package:plate_core/plate_core.dart';

import 'sint_maarten_colors.dart';

/// Sint Maarten as a `PlateCountry`. The plate prints no country block, so
/// every spec sets `noPanel`. The national flag is not carried: it holds the
/// coat of arms, which is not a shape the drawing vocabulary can express.
abstract final class SintMaartenCountry {
  static const PlateCountry sint_maarten = PlateCountry(
    code: 'sx',
    captionLines: <String>[],
    panelColor: SintMaartenColors.field,
    panelTextColor: SintMaartenColors.black,
  );
}
