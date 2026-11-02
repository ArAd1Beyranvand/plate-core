import 'package:flutter/widgets.dart';

/// Modal colours of regions in Wikipedia/Commons reference images.
///
/// Values marked `// CALIBRATE` come from photographs, where plastic ages and
/// aluminium gets dirty; JPJ publishes no colour values.
abstract final class MalaysiaColors {
  static const Color black = Color(0xFF1C1C1C); // CALIBRATE
  static const Color lightInk = Color(0xFFE8E0D0); // CALIBRATE

  /// The taxi field: reflective aluminium under daylight, sampled as a light
  /// grey-blue.
  static const Color taxiField = Color(0xFF808088); // CALIBRATE
  static const Color darkInk = Color(0xFF000000);

  /// The diplomatic red, sampled on the lit half of the photograph.
  static const Color diplomaticRed = Color(0xFFA8363C); // CALIBRATE
  static const Color diplomaticInk = Color(0xFFD4CCD0); // CALIBRATE
  static const Color evField = Color(0xFFFFFFFF);
  static const Color evGreen = Color(0xFF8DBF22);
  static const Color evSecureStrip = Color(0xFFF1F1F1);
  static const Color inactiveOnDark = Color(0xFF5A5A5A);
  static const Color inactiveOnLight = Color(0xFFB0B0B0);
}
