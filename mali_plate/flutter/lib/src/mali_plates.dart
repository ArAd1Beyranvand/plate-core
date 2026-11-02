import 'dart:math';

import 'package:plate_core/plate_core.dart';

import 'mali_alphabets.dart';
import 'mali_country.dart';

/// Millimetres on a 520×110 single-line plate (`AB 1234 MD`), measured off
/// the Wikimedia reference image. Corners and frame are the theme's; the serial
/// is centred vertically and spread across the width.
abstract final class _Layout {
  static const double width = 520;
  static const double height = 110;

  static const double textCenter = 55;

  /// Slot height for ~35 mm of ink, given the 0.72 glyph ratio.
  static const double glyphHeight = 50;

  static const double leftLettersLeft = 45;
  static const double digitsLeft = 245;
  static const double rightLettersLeft = 430;

  static const double cellWidth = 45;
}

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

PlateSlot _field(PlateAlphabet alphabet, int count, double left, double top) =>
    PlateSlot(
      alphabet: alphabet,
      box: PlateBox(left, top, count * _Layout.cellWidth, _Layout.glyphHeight),
      length: count,
      spacing: max(0, _Layout.cellWidth - 0.6 * 0.72 * _Layout.glyphHeight),
    );

abstract final class MaliPlates {
  static final Map<String, PlateSpec Function()> all =
      <String, PlateSpec Function()>{'standard': maliStandardPlate};
}
