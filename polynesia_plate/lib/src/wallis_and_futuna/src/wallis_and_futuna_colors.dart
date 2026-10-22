import 'package:flutter/widgets.dart';

/// The rear yellow and its ink are the offline stage's colour-balanced values
/// from the photo `French_number_plate_sample_from_Wallis_and_Futuna__988_`
/// (field DCA239, ink 040204); the front plate is plain white and black. The
/// EU blue is the standard one.
abstract final class WallisAndFutunaColors {
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color yellow = Color(0xFFDCA239);
  static const Color yellowInk = Color(0xFF040204);
  static const Color euroBlue = Color(0xFF003399);
  static const Color inactive = Color(0xFFB0B0B0);
}
