import 'package:flutter/widgets.dart';

/// Eritrea plate colours. The reference photo is flattened and balanced to a
/// white field (`FFFFFF`) and `1F1F1F` ink, so those are the sampled values.
abstract final class EritreaColors {
  static const Color white = Color(0xFFFFFFFF);

  /// Ink and rim: modal pixel of the flattened photo.
  static const Color ink = Color(0xFF1F1F1F);

  /// Flag blue (`#4189dd` in the Wikimedia SVG), for hosts.
  static const Color flagBlue = Color(0xFF4189DD);

  static const Color inactive = Color(0xFFB0B0B0);
}
