import 'package:flutter/widgets.dart';

/// Colours of the 2005–2019 plates, each the modal colour of a region of one
/// flattened photo (brief fit `ok`), white-balanced by the offline stage.
abstract final class BonaireColors {
  /// 2013 field. `Bonaire_2013_truck_license_plate`: `CBC8CA`.
  static const Color white = Color(0xFFCBC8CA);

  /// Its ink: `2E2D2E`.
  static const Color black = Color(0xFF2E2D2E);

  /// "BONAIRE" on the 2013 plate, modal blue of the caption row: `3850A8`.
  static const Color caption = Color(0xFF3850A8);

  /// Sky and sea in the 2013 landscape strip: `239DCB` and `3485BA`.
  static const Color sky = Color(0xFF239DCB);
  static const Color sea = Color(0xFF3485BA);

  /// 2005–2007 field. `License_Plate_in_Bonaire__2005-2007_`: `243B59`.
  static const Color navy = Color(0xFF243B59);

  /// Its ink: `E7E1D6`.
  static const Color cream = Color(0xFFE7E1D6);

  /// St. Eustatius field (the photo is a blue underwater scene, one blue
  /// stands for it): `20478D`; ink `93B9E0`.
  static const Color statiaBlue = Color(0xFF20478D);
  static const Color statiaInk = Color(0xFF93B9E0);

  /// Saba field and ink, `Caribbean_Netherlands_license_plate__Saba_`
  /// (unflattened original): `90C090` and `E9E8ED`.
  static const Color sabaGreen = Color(0xFF90C090);
  static const Color sabaInk = Color(0xFFE9E8ED);

  static const Color inactive = Color(0xFFB0B0B0);
}
