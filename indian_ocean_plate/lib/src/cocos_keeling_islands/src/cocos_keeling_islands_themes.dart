import 'package:plate_core/plate_core.dart';

import 'cocos_keeling_islands_colors.dart';

/// Blue on pale grey with a blue frame line. The frame is ~1.5 of 118 photo
/// units, so 0.012.
abstract final class CocosKeelingIslandsThemes {
  static final PlateTheme general = PlateTheme.monochrome(
    field: CocosKeelingIslandsColors.field,
    ink: CocosKeelingIslandsColors.ink,
    inactive: CocosKeelingIslandsColors.inactive,
    borderWidthRatio: 0.012,
    plateRadiusRatio: 0.04,
  );
}
