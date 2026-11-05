import 'package:flutter/widgets.dart';

/// The colours of the Riyadh plate. Field and ink are shared; only the strip
/// varies. Strip colours are sampled from the Wikipedia artwork, not the
/// article's adjectives: "silver" is a light grey, "green" a pure green.
abstract final class RiyadhColors {
  static const Color white = Color(0xFFFFFFFF);
  static const Color ink = Color(0xFF000000);

  /// Public transport and taxis.
  static const Color yellow = Color(0xFFFFC913);

  /// Commercial.
  static const Color blue = Color(0xFF0079C1);

  /// Temporary.
  static const Color silver = Color(0xFFC3C3C3);

  /// Diplomatic.
  static const Color green = Color(0xFF22B14C);

  /// The hologram sticker on the strip, as the artwork renders it (censored).
  static const Color hologram = Color(0xFF898F9E);
}
