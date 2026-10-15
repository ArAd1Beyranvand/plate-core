import 'package:flutter/widgets.dart';

/// The colours of the 2006 Zimbabwean plates.
///
/// [yellow] and [yellowStacked] are sampled: the median of the stroke
/// interiors of one flattened photo each, white-balanced against a known white
/// in the same photo. They differ because they are two photos of two plates in
/// different light, and one photo each cannot say which is the paint.
/// [white], [red] and [black] are NOT sampled: no photo shows a white or a
/// commercial plate, and the article only names the colours.
abstract final class ZimbabweColors {
  /// Single-row private field. `Zimbabwe_car_plate`: `F19B18`.
  static const Color yellow = Color(0xFFF19B18);

  /// Its ink, same photo: `474852`, lifted by glare on the embossed paint.
  static const Color yellowInk = Color(0xFF474852);

  /// Stacked private field. `Zimbabwe_license_plate_square`: `D9AC1D`.
  static const Color yellowStacked = Color(0xFFD9AC1D);

  /// Its ink, same photo: `1C1E1E`.
  static const Color stackedInk = Color(0xFF1C1E1E);

  /// Unsampled: the article's "white backgrounds".
  static const Color white = Color(0xFFFFFFFF); // CALIBRATE

  /// Unsampled: the article's "red on a white background".
  static const Color red = Color(0xFFC8102E); // CALIBRATE

  /// Unsampled black ink for the white plate.
  static const Color black = Color(0xFF1C1E1E); // CALIBRATE

  static const Color inactive = Color(0xFFB0B0B0);
}
