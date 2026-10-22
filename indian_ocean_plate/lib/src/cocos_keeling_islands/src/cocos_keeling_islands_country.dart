import 'package:plate_core/plate_core.dart';

import 'cocos_keeling_islands_colors.dart';

/// Cocos (Keeling) Islands as a `PlateCountry`. The plate carries no flag or
/// country block (the name is a caption in the spec), so every spec sets
/// `noPanel`.
abstract final class CocosKeelingIslandsCountry {
  static const PlateCountry cocos_keeling_islands = PlateCountry(
    code: 'cc',
    captionLines: <String>[],
    panelColor: CocosKeelingIslandsColors.field,
    panelTextColor: CocosKeelingIslandsColors.ink,
  );
}
