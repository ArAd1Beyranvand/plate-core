import 'package:flutter/widgets.dart';

/// The colours of the Italian plates. Every plate is black on white with the
/// EU band, so the artwork's own values are used: white, black and the band's
/// `033FA2` and ring yellow `FFCC00` are the modal pixels of the vector
/// reference (`1999_CZ_889_KF`). The photographed two-line and motorcycle
/// plates carry their photo's lighting (their blues sample from `1F579E` to
/// `03609D`), so they are not used.
abstract final class ItalyColors {
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color euroBlue = Color(0xFF033FA2);
  static const Color ringYellow = Color(0xFFFFCC00);
  static const Color inactive = Color(0xFFB0B0B0);
}
