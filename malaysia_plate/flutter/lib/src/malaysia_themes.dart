import 'package:flutter/widgets.dart';
import 'package:plate_core/plate_core.dart';

import 'malaysia_colors.dart';

/// One ink on one field per livery. A standard plate is frameless (the chrome
/// surrounds in photos are dealer frames), so the border is drawn in the field
/// colour and disappears; only the JPJePlate has a printed black rim.
abstract final class MalaysiaThemes {
  static const double _plateRadiusRatio = 0.04; // CALIBRATE

  static PlateTheme _field({
    required Color field,
    required Color ink,
    required Color inactive,
    Color? rim,
    double borderWidthRatio = 0.02,
  }) => PlateTheme(
    plateBackground: field,
    plateBorder: rim ?? field,
    ink: ink,
    dividerColor: ink,
    borderWidthRatio: borderWidthRatio,
    plateRadiusRatio: _plateRadiusRatio,
    activeColor: ink,
    inactiveColor: inactive,
    alertColor: const Color(0xFFD32F2F),
  );

  /// Private and commercial vehicles, and the military `Z` series.
  static final PlateTheme standard = _field(
    field: MalaysiaColors.black,
    ink: MalaysiaColors.lightInk,
    inactive: MalaysiaColors.inactiveOnDark,
  );

  /// Taxis and hire cars, `H` series.
  static final PlateTheme taxi = _field(
    field: MalaysiaColors.taxiField,
    ink: MalaysiaColors.darkInk,
    inactive: MalaysiaColors.inactiveOnLight,
  );

  /// The diplomatic corps (`DC`) and, on some plates, `UN`.
  static final PlateTheme diplomatic = _field(
    field: MalaysiaColors.diplomaticRed,
    ink: MalaysiaColors.diplomaticInk,
    inactive: MalaysiaColors.inactiveOnDark,
  );

  /// Consular (`CC`) and international-organisation (`PA`) plates: the
  /// diplomatic geometry on the standard colours.
  static final PlateTheme consular = standard;

  /// The JPJePlate. The artwork's rim lies outside the interior mapped to
  /// 520 mm, so at its true 8 mm it would cover MAL; the thinner rim clears
  /// the strip's wording.
  static final PlateTheme ev = _field(
    field: MalaysiaColors.evField,
    ink: MalaysiaColors.darkInk,
    inactive: MalaysiaColors.inactiveOnLight,
    rim: MalaysiaColors.darkInk,
    borderWidthRatio: 0.03,
  );
}
