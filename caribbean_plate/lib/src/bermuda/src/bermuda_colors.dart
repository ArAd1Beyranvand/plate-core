import 'package:flutter/widgets.dart';

/// The colours of a Bermudian plate.
///
/// Sampled from the modal pixels of `Bermuda_license_plate_graphic`, the
/// clean artwork of the current private plate. The 1960s plate (white on
/// black) is a photograph of a historic series and is not implemented.
abstract final class BermudaColors {
  /// Plate field. Artwork: `FCFCFC`.
  static const Color white = Color(0xFFFCFCFC);

  /// Digits and letters. Artwork: `000000`.
  static const Color black = Color(0xFF000000);

  static const Color inactive = Color(0xFFB0B0B0);
}
