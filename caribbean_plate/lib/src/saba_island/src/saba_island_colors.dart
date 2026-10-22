import 'package:flutter/widgets.dart';

/// Colours of the 2011 and 1978 Saba plates, each the modal colour of a
/// region of the reference.
abstract final class SabaIslandColors {
  /// 2011 field. `Caribbean_Netherlands_license_plate__Saba_` (unflattened
  /// original, unbalanced): `8DBC88`.
  static const Color green = Color(0xFF8DBC88);

  /// 2011 embossed ink: `E9E8ED`.
  static const Color white = Color(0xFFE9E8ED);

  /// 1978 field. `SABA_N.A._1978_license_plate`, flattened: `CDBEB7`.
  static const Color cream = Color(0xFFCDBEB7);

  /// 1978 ink and rim: `154655`.
  static const Color teal = Color(0xFF154655);

  static const Color inactive = Color(0xFFB0B0B0);
}
