import 'package:plate_core/plate_core.dart';

import 'sint_eustatius_colors.dart';

/// Sint Eustatius (a Caribbean Netherlands island, ISO `BQ`) as a
/// `PlateCountry`. No plate carries a country block, so every spec sets
/// `noPanel`.
abstract final class SintEustatiusCountry {
  static const PlateCountry sint_eustatius = PlateCountry(
    code: 'bq',
    captionLines: <String>[],
    panelColor: SintEustatiusColors.blue,
    panelTextColor: SintEustatiusColors.blueInk,
  );
}
