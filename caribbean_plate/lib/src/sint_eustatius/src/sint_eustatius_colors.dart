import 'package:flutter/widgets.dart';

/// Each colour is the modal colour of a region of one flattened photo
/// (brief fit `ok`), white-balanced by the offline stage.
abstract final class SintEustatiusColors {
  /// 2007 field. `2007_license_plate_Saint_Eustatius`: `20478D`. The photo is
  /// an underwater scene; one blue stands for it.
  static const Color blue = Color(0xFF20478D);

  /// Its ink: `93B9E0`.
  static const Color blueInk = Color(0xFF93B9E0);

  /// 1976 field. `ST._EUSTATIUS_N.A._1976_...`: `CFD2CE`.
  static const Color white = Color(0xFFCFD2CE);

  /// Its serial and slogan ink: `51181F`.
  static const Color maroon = Color(0xFF51181F);

  /// Its frame line, modal colour of the inner border, `80131F` (JPEG noise
  /// of a few units either way).
  static const Color red = Color(0xFF80131F);

  static const Color inactive = Color(0xFFB0B0B0);
}
