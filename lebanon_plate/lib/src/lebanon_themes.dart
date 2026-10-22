import 'package:flutter/widgets.dart';
import 'package:plate_core/plate_core.dart';

import 'lebanon_colors.dart';
import 'lebanon_usage.dart';

/// One `PlateTheme` per `LebanonUsage`: a field colour with dark or light ink.
/// The host passes a spec for geometry and a theme from [forUsage] for colour.
abstract final class LebanonThemes {
  /// Border thickness as a fraction of plate height; a thin frame set well
  /// inside the edge.
  static const double _borderWidthRatio = 0.022; // CALIBRATE

  static const double _plateRadiusRatio = 0.045; // CALIBRATE

  static PlateTheme _field({required Color field, required Color ink, required Color inactive}) =>
      PlateTheme(
        plateBackground: field,
        plateBorder: LebanonColors.frame,
        ink: ink,
        dividerColor: LebanonColors.frame,
        borderWidthRatio: _borderWidthRatio,
        plateRadiusRatio: _plateRadiusRatio,
        activeColor: ink,
        inactiveColor: inactive,
        alertColor: const Color(0xFFD32F2F),
      );

  static final PlateTheme private = _field(
    field: LebanonColors.white,
    ink: LebanonColors.darkInk,
    inactive: LebanonColors.inactiveOnLight,
  );

  static final PlateTheme consular = _field(
    field: LebanonColors.purple,
    ink: LebanonColors.lightInk,
    inactive: LebanonColors.inactiveOnDark,
  );

  static final PlateTheme diplomatic = _field(
    field: LebanonColors.orange,
    ink: LebanonColors.darkInk,
    inactive: LebanonColors.inactiveOnLight,
  );

  static final PlateTheme publicInstitution = _field(
    field: LebanonColors.red,
    ink: LebanonColors.lightInk,
    inactive: LebanonColors.inactiveOnDark,
  );

  static final PlateTheme drivingSchool = _field(
    field: LebanonColors.yellow,
    ink: LebanonColors.darkInk,
    inactive: LebanonColors.inactiveOnLight,
  );

  static final PlateTheme transit = _field(
    field: LebanonColors.green,
    ink: LebanonColors.lightInk,
    inactive: LebanonColors.inactiveOnDark,
  );

  static final PlateTheme temporary = _field(
    field: LebanonColors.brown,
    ink: LebanonColors.lightInk,
    inactive: LebanonColors.inactiveOnDark,
  );

  static final PlateTheme tourism = _field(
    field: LebanonColors.pink,
    ink: LebanonColors.darkInk,
    inactive: LebanonColors.inactiveOnLight,
  );

  /// [LebanonUsage.publicTransport] inherits the red of public institutions
  /// (unattested).
  static PlateTheme forUsage(LebanonUsage usage) => switch (usage) {
    LebanonUsage.private => private,
    LebanonUsage.consular => consular,
    LebanonUsage.diplomatic => diplomatic,
    LebanonUsage.publicInstitution => publicInstitution,
    LebanonUsage.publicTransport => publicInstitution,
    LebanonUsage.drivingSchool => drivingSchool,
    LebanonUsage.transit => transit,
    LebanonUsage.temporary => temporary,
    LebanonUsage.tourism => tourism,
  };
}
