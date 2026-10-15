import 'package:flutter/widgets.dart';

/// The colours of the Dutch plates, sampled from the flattened references
/// (modal pixel of the region, `.plateref/nl`).
///
/// The standard field `FFD101` and ink `000000` are the modal pixels of the
/// clean `Dutch_plate_yellow_NL_code_*` renders; the EU panel `0000B7` is the
/// same renders' blue (they are not the flag's official `003399`). The
/// photographs of the royal, trailer and Grens Verkeer plates read orange or
/// pale under their own lighting, but the plates are the same reflective
/// yellow, so they share it. The dealer plate is the one green field
/// (`50B25E`, median of the photograph) and the BFG plate light on dark grey
/// (`383837` / `F0F0F0`, estimated from a 250 px photograph).
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
