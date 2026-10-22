import 'package:flutter/widgets.dart';

/// Sampled from photographs (median of the field and of the eroded ink mask,
/// inside the rim). No artwork or official values exist, so these carry each
/// photo's lighting; where several photos show one paint, the median of them.
abstract final class TunisiaColors {
  /// Field of the ordinary, military and temporary plates.
  static const Color black = Color(0xFF262621);

  /// Ink on every dark plate.
  static const Color white = Color(0xFFDDDACD);

  /// The pressed aluminium rim of the ordinary and rental plates.
  static const Color rimSilver = Color(0xFFB3B6B2);

  static const Color rentalBlue = Color(0xFF054980);

  /// Government plate: field and ink.
  static const Color governmentWhite = Color(0xFFF0EEF1);
  static const Color governmentRed = Color(0xFFC72431);

  /// Diplomatic plate: field and ink. The field is a white in partial shade.
  static const Color diplomaticWhite = Color(0xFFE7E7E7);
  static const Color diplomaticBlack = Color(0xFF1B1B1D);

  /// The official flag red, for hosts.
  static const Color flagRed = Color(0xFFE70013);

  static const Color inactiveOnDark = Color(0xFF8A8A8A);
  static const Color inactiveOnLight = Color(0xFFB0B0B0);
}
