import 'package:plate_core/plate_core.dart';

import 'palestine_colors.dart';
import 'palestine_usage.dart';

abstract final class PSThemes {
  /// Measured from `pics/reference_plate.png`.
  static const double _borderWidthRatio = 0.027, _plateRadiusRatio = 0.10;

  // --- West Bank -----------------------------------------------------------

  /// Green on white: private, leased, police (ordinary West Bank plate).
  static const PlateTheme greenOnWhite = PlateTheme.monochrome(
    field: PSColors.white,
    ink: PSColors.green,
    inactive: PSColors.inactiveGreen,
    borderWidthRatio: _borderWidthRatio,
    plateRadiusRatio: _plateRadiusRatio,
  );

  /// White on green: public transport. The only inverted West Bank scheme.
  static const PlateTheme whiteOnGreen = PlateTheme.monochrome(
    field: PSColors.green,
    ink: PSColors.white,
    inactive: PSColors.inactiveOnDark,
    borderWidthRatio: _borderWidthRatio,
    plateRadiusRatio: _plateRadiusRatio,
  );

  /// Red on white: government and duty-exempt (ambulance, fire, civil defence).
  static const PlateTheme redOnWhite = PlateTheme.monochrome(
    field: PSColors.white,
    ink: PSColors.red,
    inactive: PSColors.inactiveNeutral,
    borderWidthRatio: _borderWidthRatio,
    plateRadiusRatio: _plateRadiusRatio,
  );

  /// White on blue: dealer and inspection (trade / test) plate.
  static const PlateTheme whiteOnBlue = PlateTheme.monochrome(
    field: PSColors.blue,
    ink: PSColors.white,
    inactive: PSColors.inactiveOnDark,
    borderWidthRatio: _borderWidthRatio,
    plateRadiusRatio: _plateRadiusRatio,
  );

  /// Commercial and municipality resolve to Gaza themes.
  static PlateTheme forUsage(PSUsage usage) => switch (usage) {
    PSUsage.private || PSUsage.leased || PSUsage.police => greenOnWhite,
    PSUsage.publicTransport => whiteOnGreen,
    PSUsage.government || PSUsage.exempt => redOnWhite,
    PSUsage.tradePlate => whiteOnBlue,
    PSUsage.commercial => gazaGreen,
    PSUsage.municipality => gazaBlue,
  };

  // --- Gaza ----------------------------------------------------------------
  // The field is always white; only glyphs, border and rules change.

  /// Black glyphs: Gaza private cars (codes 00–09).
  static const PlateTheme gazaBlack = PlateTheme.monochrome(
    field: PSColors.white,
    ink: PSColors.black,
    inactive: PSColors.inactiveNeutral,
    borderWidthRatio: _borderWidthRatio,
    plateRadiusRatio: _plateRadiusRatio,
  );

  /// Green glyphs: Gaza commercial vehicles (codes 10–19).
  static const PlateTheme gazaGreen = PlateTheme.monochrome(
    field: PSColors.white,
    ink: PSColors.gazaCommercialGreen,
    inactive: PSColors.inactiveGreen,
    borderWidthRatio: _borderWidthRatio,
    plateRadiusRatio: _plateRadiusRatio,
  );

  /// Blue glyphs: Gaza public transport, taxis (20–29), municipality (40–49).
  static const PlateTheme gazaBlue = PlateTheme.monochrome(
    field: PSColors.white,
    ink: PSColors.blue,
    inactive: PSColors.inactiveNeutral,
    borderWidthRatio: _borderWidthRatio,
    plateRadiusRatio: _plateRadiusRatio,
  );

  /// Red glyphs: Gaza government (police, ambulances; codes 50–59).
  static const PlateTheme gazaRed = PlateTheme.monochrome(
    field: PSColors.white,
    ink: PSColors.red,
    inactive: PSColors.inactiveNeutral,
    borderWidthRatio: _borderWidthRatio,
    plateRadiusRatio: _plateRadiusRatio,
  );

  /// Null if [code] is unallocated.
  static PlateTheme? forGazaUsageCode(String code) {
    return switch (PSGazaUsage.forCode(code)) {
      PSUsage.private => gazaBlack,
      PSUsage.commercial => gazaGreen,
      PSUsage.publicTransport || PSUsage.municipality => gazaBlue,
      PSUsage.government => gazaRed,
      _ => null,
    };
  }
}
