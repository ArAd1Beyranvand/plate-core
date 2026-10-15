import 'dart:math';

import 'package:plate_core/plate_core.dart';

import 'mali_alphabets.dart';
import 'mali_country.dart';

/// Where the ink sits on a Mali plate, in millimetres.
///
/// Mali's current series is a simple single-line format: 520×110 mm, rounded
/// corners, black on white, with the format AB 1234 MD (2 letters, 4 digits,
/// 2 letters). Measured off the Wikimedia reference image, normalised to
/// physical millimetres.
///
/// The single plate has:
/// * Rounded corner radius: ~15 mm (approximately 15% of height)
/// * Frame width: ~3 mm
/// * Serial ink positioned centred vertically and distributed horizontally
///   across the width with proportional spacing.
abstract final class _Layout {
  static const double width = 520;
  static const double height = 110;

  /// Vertical centre of the text area.
  static const double textCenter = 55;

  /// Glyph height — calculated from the 0.72 ratio: ink height is ~35 mm,
  /// so slot height should be about 49 mm.
  static const double glyphHeight = 50;

  /// Spacing: the reference shows evenly distributed spacing.
  /// Left letter pair positioned at ~45 mm from left edge.
  static const double leftLettersLeft = 45;

  /// Digits centred at ~260 mm (midpoint of the plate).
  static const double digitsLeft = 245;

  /// Right letters at ~430 mm from left edge.
  static const double rightLettersLeft = 430;

  /// Cell width for letters and digits.
  static const double cellWidth = 45;
}

/// Mali's current standard plate: black on white, format AB 1234 MD.
PlateSpec maliStandardPlate() {
  const double top = _Layout.textCenter - _Layout.glyphHeight / 2;

  return PlateSpec(
    id: 'ml.standard',
    country: MaliCountry.mali,
    canvasWidth: _Layout.width,
    canvasHeight: _Layout.height,
    noPanel: true,
    panel: const PlatePanel(box: PlateBox(0, 0, 0, _Layout.height)),
    background: PlateSection.plain,
    slots: <PlateSlot>[
      _field(MaliAlphabets.letters, 2, _Layout.leftLettersLeft, top),
      _field(MaliAlphabets.digits, 4, _Layout.digitsLeft, top),
      _field(MaliAlphabets.letters, 2, _Layout.rightLettersLeft, top),
    ],
    textGroups: const <PlateTextGroup>[
      PlateTextGroup(<int>[0], key: 'prefix'),
      PlateTextGroup(<int>[1], key: 'number'),
      PlateTextGroup(<int>[2], key: 'suffix'),
    ],
  );
}

/// One field of [count] cells from [left], spaced to the cell width.
PlateSlot _field(PlateAlphabet alphabet, int count, double left, double top) =>
    PlateSlot(
      alphabet: alphabet,
      box: PlateBox(left, top, count * _Layout.cellWidth, _Layout.glyphHeight),
      length: count,
      spacing: max(0, _Layout.cellWidth - 0.6 * 0.72 * _Layout.glyphHeight),
    );

/// All Mali plate specs, keyed by a simple name.
abstract final class MaliPlates {
  static final Map<String, PlateSpec Function()> all =
      <String, PlateSpec Function()>{'standard': maliStandardPlate};
}
