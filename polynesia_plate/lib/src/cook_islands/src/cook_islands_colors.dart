import 'package:flutter/widgets.dart';

/// The colours of the Cook Islands plates.
///
/// [yellow] and [green] come from the offline fit of the car-plate artwork
/// (`FFFF00`, `008000`). [amber] is the bucketed mode of the yellow pixels in
/// the motorcycle photograph and [amberInk] is NOT sampled: the photo's plates
/// are about 30 px wide and the ink is a guess at near-black.
abstract final class CookIslandsColors {
  static const Color yellow = Color(0xFFFFFF00);
  static const Color green = Color(0xFF008000);

  static const Color amber = Color(0xFFF0B848);
  static const Color amberInk = Color(0xFF1C1E1E); // CALIBRATE

  static const Color inactive = Color(0xFFB0B0B0);
}
