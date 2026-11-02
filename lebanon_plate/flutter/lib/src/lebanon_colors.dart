import 'package:flutter/widgets.dart';

/// Every colour a Lebanese plate is printed in, all from photographs. Colours
/// go into `LebanonThemes` and `LebanonCountry`, never into specs.
abstract final class LebanonColors {
  static const Color band = Color(0xFF0D63B5); // CALIBRATE
  static const Color bandInk = Color(0xFFFFFFFF); // CALIBRATE

  /// Private vehicles and the uncoloured letter classes.
  static const Color white = Color(0xFFFFFFFF); // CALIBRATE

  /// Consular vehicles (C).
  static const Color purple = Color(0xFF7B3F98); // CALIBRATE

  /// Diplomatic vehicles (D).
  static const Color orange = Color(0xFFE87722); // CALIBRATE

  /// Public institutions, and formerly public transport.
  static const Color red = Color(0xFFC8102E); // CALIBRATE

  /// Driving-school vehicles.
  static const Color yellow = Color(0xFFF6C400); // CALIBRATE

  /// Transit vehicles.
  static const Color green = Color(0xFF1B7A3D); // CALIBRATE

  /// Temporary registration.
  static const Color brown = Color(0xFF6B4423); // CALIBRATE

  /// Tourism vehicles.
  static const Color pink = Color(0xFFE8618C); // CALIBRATE

  /// Ink on white, yellow, orange and pink fields.
  static const Color darkInk = Color(0xFF111111); // CALIBRATE

  /// Ink on purple, red, green and brown fields.
  static const Color lightInk = Color(0xFFFFFFFF); // CALIBRATE

  static const Color frame = Color(0xFF111111); // CALIBRATE
  static const Color inactiveOnLight = Color(0x66666666); // CALIBRATE
  static const Color inactiveOnDark = Color(0x66FFFFFF); // CALIBRATE
}
