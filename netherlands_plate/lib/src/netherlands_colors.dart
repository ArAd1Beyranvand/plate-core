import 'package:flutter/widgets.dart';

/// Modal pixels of the flattened references (`.plateref/nl`).
///
/// The yellow field, black ink and EU blue come from the clean
/// `Dutch_plate_yellow_NL_code_*` renders; the blue is theirs, not the flag's
/// official `003399`. Photographed royal, trailer and Grens Verkeer plates
/// read orange or pale under their lighting but are the same reflective
/// yellow. Dealer green and the BFG grey are estimated from 250 px photos.
abstract final class NetherlandsColors {
  static const Color yellow = Color(0xFFFFD101);
  static const Color black = Color(0xFF000000);
  static const Color euBlue = Color(0xFF0000B7);
  static const Color euInk = Color(0xFFFFFFFF);

  static const Color dealerGreen = Color(0xFF50B25E);
  static const Color dealerInk = Color(0xFF1B1B1B);

  static const Color bfgField = Color(0xFF383837);
  static const Color bfgInk = Color(0xFFF0F0F0);

  static const Color inactive = Color(0xFFB0B0B0);
}
