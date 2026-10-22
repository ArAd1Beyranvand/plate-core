import 'package:plate_core/plate_core.dart';

import 'lebanon_colors.dart';
import 'lebanon_usage.dart';

/// Lebanon's blue band, the same on every usage; colour-coding is the field.
///
/// All variants share `code: 'lb'`, so distinguish them by [PlateSpec.id].
/// لبنان is a [PlateLabel] on the spec, not part of the band.
abstract final class LebanonCountry {
  /// The band with no usage word, for classes whose printed Arabic is not
  /// attested (see `LebanonUsage.arabic`).
  static const PlateCountry band = PlateCountry(
    code: 'lb',
    captionLines: <String>[],
    panelColor: LebanonColors.band,
    panelTextColor: LebanonColors.bandInk,
    flag: SvgPlateAsset('assets/cedar.svg', package: 'lebanon_plate'),
    flagAspectRatio: 1.0,
  );

  static const PlateCountry private = PlateCountry(
    code: 'lb',
    captionLines: <String>['خصوصي'],
    panelColor: LebanonColors.band,
    panelTextColor: LebanonColors.bandInk,
    flag: SvgPlateAsset('assets/cedar.svg', package: 'lebanon_plate'),
    flagAspectRatio: 1.0,
  );

  static const PlateCountry publicInstitution = PlateCountry(
    code: 'lb',
    captionLines: <String>['مؤسسات'],
    panelColor: LebanonColors.band,
    panelTextColor: LebanonColors.bandInk,
    flag: SvgPlateAsset('assets/cedar.svg', package: 'lebanon_plate'),
    flagAspectRatio: 1.0,
  );

  /// The band captioned for [usage], or uncaptioned when the Arabic word is not
  /// attested. Check [LebanonUsage.arabic] to grey an option out.
  static PlateCountry forUsage(LebanonUsage usage) => switch (usage.arabic) {
    'خصوصي' => private,
    'مؤسسات' => publicInstitution,
    _ => band,
  };
}
