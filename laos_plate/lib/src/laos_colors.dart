import 'package:flutter/widgets.dart';

/// The colours of the 2001 Lao plates.
///
/// Every reference is a photograph, so a raw sample is the paint times the
/// light. Each value is the median of eroded stroke interiors of one
/// flattened photo, rescaled per channel so a known white in that photo (the
/// field, the ink, a sticker or the car's paint) reads `FFFFFF`.
abstract final class LaosColors {
  /// Private field. `Laos_Private_Car…`, against its emblem sticker: `FFDC00`.
  static const Color yellow = Color(0xFFFFDC00);

  /// Private EV field. `Laos_Private_Electric_Car…`, against its sticker:
  /// `FFAF00`. Balanced the same way as [yellow] it is still 45 lower in
  /// green; one photo each cannot say whether that is paint or sky, so the
  /// two stay apart.
  static const Color amber = Color(0xFFFFAF00);

  /// Government field. `Laos_Government_Car…`, against its white ink:
  /// `1E81F5`.
  static const Color governmentBlue = Color(0xFF1E81F5);

  /// Taxable-company ink and frame. `Laos_Taxable_Company_Car…`, against its
  /// white field: `01A3F7`, a sky blue.
  static const Color taxableBlue = Color(0xFF01A3F7);

  /// International-organisation field. `Laos_diplomatic…`, against the
  /// white car body under the plate (its sticker is in shade): `D0D0D0`.
  static const Color silver = Color(0xFFD0D0D0);

  /// International-organisation ink and frame, same photo: `38A5EF`. Paler
  /// and greyer than [taxableBlue]; a second blue.
  static const Color paleBlue = Color(0xFF38A5EF);

  /// Police field. `License_plates_of_Laos`, against its white ink: `DC303C`.
  static const Color red = Color(0xFFDC303C);

  /// Black ink of the private, company and temporary plates: the median of
  /// four corrected samples that differ by emboss sheen, not colour.
  static const Color black = Color(0xFF2D2B2D);

  static const Color white = Color(0xFFFFFFFF);

  /// The 2024 EV badge, against its own white letters: `2CCF47`. The company
  /// EV photo's paler `82D47A` is glare on a glossy sticker.
  static const Color evGreen = Color(0xFF2CCF47);

  static const Color inactive = Color(0xFFB0B0B0);
}
