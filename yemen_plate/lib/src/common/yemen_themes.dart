import 'package:plate_core/plate_core.dart';

import 'yemen_colors.dart';
import 'yemen_usage.dart';

/// The themes a Yemeni plate is printed in. System A has one; System B has one
/// per usage colour, picked by [forNorthernUsage]. The southern plates have
/// their own, measured from the artwork.
abstract final class YemenThemes {
  static const double _borderWidthRatio = 0.035; // CALIBRATE

  static const double _unifiedRadiusRatio = 0.055; // CALIBRATE

  /// System A: black on white. The divider colour paints the stipple strip.
  static const PlateTheme unified = PlateTheme.monochrome(
    field: YemenColors.unifiedField,
    ink: YemenColors.unifiedInk,
    inactive: YemenColors.inactiveOnLight,
    borderWidthRatio: _borderWidthRatio,
    plateRadiusRatio: _unifiedRadiusRatio,
  );

  static const PlateTheme northernPrivate = PlateTheme.monochrome(
    field: YemenColors.blue,
    ink: YemenColors.darkInk,
    inactive: YemenColors.inactiveOnDark,
    borderWidthRatio: _borderWidthRatio,
    plateRadiusRatio: _unifiedRadiusRatio,
  );

  /// Private vehicles on white: black on white.
  static const PlateTheme northernPrivateWhite = PlateTheme.monochrome(
    field: YemenColors.white,
    ink: YemenColors.darkInk,
    inactive: YemenColors.inactiveOnLight,
    borderWidthRatio: _borderWidthRatio,
    plateRadiusRatio: _unifiedRadiusRatio,
  );

  static const PlateTheme northernForHire = PlateTheme.monochrome(
    field: YemenColors.yellow,
    ink: YemenColors.darkInk,
    inactive: YemenColors.inactiveOnLight,
    borderWidthRatio: _borderWidthRatio,
    plateRadiusRatio: _unifiedRadiusRatio,
  );

  static const PlateTheme northernTransport = PlateTheme.monochrome(
    field: YemenColors.red,
    ink: YemenColors.darkInk,
    inactive: YemenColors.inactiveOnDark,
    borderWidthRatio: _borderWidthRatio,
    plateRadiusRatio: _unifiedRadiusRatio,
  );

  static const PlateTheme northernGovernment = PlateTheme.monochrome(
    field: YemenColors.green,
    ink: YemenColors.lightInk,
    inactive: YemenColors.inactiveOnDark,
    borderWidthRatio: _borderWidthRatio,
    plateRadiusRatio: _unifiedRadiusRatio,
  );

  /// The long-standing military printing: white on black.
  static const PlateTheme northernMilitaryClassic = PlateTheme.monochrome(
    field: YemenColors.black,
    ink: YemenColors.lightInk,
    inactive: YemenColors.inactiveOnDark,
    borderWidthRatio: _borderWidthRatio,
    plateRadiusRatio: _unifiedRadiusRatio,
  );

  /// The newer military printing: red on white.
  static const PlateTheme northernMilitaryModern = PlateTheme.monochrome(
    field: YemenColors.white,
    ink: YemenColors.militaryRed,
    inactive: YemenColors.inactiveOnLight,
    borderWidthRatio: _borderWidthRatio,
    plateRadiusRatio: _unifiedRadiusRatio,
  );

  /// The northern theme for [usage]. [style] applies only to military;
  /// [whiteBackground] prints private on white; police takes the government theme.
  static PlateTheme forNorthernUsage(
    YemenUsage usage, {
    YemenMilitaryStyle style = YemenMilitaryStyle.classic,
    bool whiteBackground = false,
  }) => switch (usage) {
    YemenUsage.private =>
      whiteBackground ? northernPrivateWhite : northernPrivate,
    YemenUsage.forHire => northernForHire,
    YemenUsage.transport => northernTransport,
    YemenUsage.government || YemenUsage.police => northernGovernment,
    YemenUsage.military => switch (style) {
      YemenMilitaryStyle.classic => northernMilitaryClassic,
      YemenMilitaryStyle.modern => northernMilitaryModern,
    },
  };

  /// [unified], since System A never recolours by usage.
  static PlateTheme forUnifiedUsage(YemenUsage usage) => unified;

  /// Hadhramaut, Al Mahrah, Shabwah and Marib: black on white, the usage colour
  /// being the strip the country block carries. Frame 5 and corner 14 on the
  /// 276-tall artwork.
  static const PlateTheme southern = PlateTheme.monochrome(
    field: YemenColors.southernField,
    ink: YemenColors.southernInk,
    inactive: YemenColors.inactiveOnLight,
    borderWidthRatio: 5 / 276,
    plateRadiusRatio: 14 / 276,
  );

  /// Aden: black on white. Frame 4.2 and corner 6.8 on the 110 mm plate; the
  /// 170 mm plate overrides the frame in its spec.
  static const PlateTheme aden = PlateTheme.monochrome(
    field: YemenColors.southernField,
    ink: YemenColors.southernInk,
    inactive: YemenColors.inactiveOnLight,
    borderWidthRatio: 4.2 / 110,
    plateRadiusRatio: 6.8 / 110,
  );

  /// Taiz temporary, first class (private and for hire): black on blue.
  /// Frame 10 and corner 20 on the 288-tall artwork.
  static const PlateTheme taizPrivate = PlateTheme.monochrome(
    field: YemenColors.southernBlue,
    ink: YemenColors.southernInk,
    inactive: YemenColors.inactiveOnDark,
    borderWidthRatio: 10 / 288,
    plateRadiusRatio: 20 / 288,
  );

  /// Taiz temporary, second class (commercial): black on red.
  static const PlateTheme taizCommercial = PlateTheme.monochrome(
    field: YemenColors.southernRed,
    ink: YemenColors.southernInk,
    inactive: YemenColors.inactiveOnDark,
    borderWidthRatio: 10 / 288,
    plateRadiusRatio: 20 / 288,
  );
}
