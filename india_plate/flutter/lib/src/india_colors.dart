import 'package:flutter/widgets.dart';

/// Every colour an Indian plate is printed in, sampled as the modal pixel of
/// each region of the colour-class artwork supplied with the task (private,
/// commercial, rental, embassy and electric plates). Wikipedia's colour table
/// gives only CSS keywords, so it decides which colour goes where, never the
/// value. Colours go into `IndiaThemes`, never into specs.
abstract final class IndiaColors {
  static const Color white = Color(0xFFFFFFFF);

  static const Color black = Color(0xFF1D1D1B);

  static const Color yellow = Color(0xFFFFFF01);

  static const Color blue = Color(0xFF86C0FF);

  static const Color green = Color(0xFF3BA936);

  /// The trade field and the temporary and military-police ink, which the
  /// artwork does not show; the temporary-plate photograph's ink is the same
  /// orange-red.
  static const Color red = Color(0xFFDB351F);

  static const Color inactive = Color(0x66666666);
}
