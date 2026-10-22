import 'package:flutter/widgets.dart';

/// Every colour a Palestinian plate is printed in. No official hex is published;
/// values marked `CALIBRATE` are provisional pending reference photographs.
abstract final class PSColors {
  /// West Bank ink, sampled from `pics/reference_plate.png`.
  static const Color green = Color(0xFF3C875D);

  /// Government and duty-exempt West Bank plates, Gaza government plates.
  // CALIBRATE — no reference image.
  static const Color red = Color(0xFFC8102E);

  /// Trade plate field, Gaza public-transport and municipality glyphs.
  // CALIBRATE — no reference image.
  static const Color blue = Color(0xFF1B4F9C);

  /// Gaza commercial plate glyphs.
  // CALIBRATE — kept apart from `green` so recalibrating one leaves the other.
  static const Color gazaCommercialGreen = Color(0xFF0F7A3D);

  /// The field of every plate in scope.
  static const Color white = Color(0xFFFFFFFF);

  /// Gaza private glyphs.
  // CALIBRATE
  static const Color black = Color(0xFF0A0A0A);

  /// Empty-slot outline for green ink.
  // CALIBRATE
  static const Color inactiveGreen = Color(0x669BC1AB);

  /// Empty-slot outline for other ink on white.
  // CALIBRATE
  static const Color inactiveNeutral = Color(0x66666666);

  /// Empty-slot outline on dark fields.
  // CALIBRATE
  static const Color inactiveOnDark = Color(0x66FFFFFF);
}
