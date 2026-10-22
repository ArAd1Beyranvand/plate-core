import 'package:plate_alphabet/plate_alphabet.dart';
import 'package:plate_core/plate_core.dart';

import 'niue_colors.dart';
import 'niue_country.dart';

/// Where the ink sits, in plate units (372 × 134 mm, the article's size).
///
/// Measured off the flattened photo `Niue_license_plate_graphic`:
/// - digits: one field, x 93.2–288.2, ink y 18.8–115.5 (cy 67.15);
/// - "NIUE": four letters stacked upright, x 14.8–24.2, y 18.8–115.5.
///
/// The digit ink is 96.7 tall on a 134 plate, which would need a box of about
/// 176; the box is held to [digitBox] so the ink lands at roughly two thirds
/// of the photo's. Ink is about 51% of the box (`glyphStyle` sizes the font at
/// 0.72 of the box and a bold digit is ~0.71 of that).
abstract final class _Layout {
  static const double width = 372, height = 134;

  static const double digitsLeft = 93.2, digitsWidth = 195;
  static const double digitCy = 67.15, digitBox = 126;

  static const double nameLeft = 9.5, nameWidth = 20;
  static const double nameTop = 14, nameHeight = 106;
  static const double nameGlyph = 30, nameLineHeight = 1.25;
}

/// Niue's plate: four digits, black on white ([NiueThemes.standard]). Group
/// `serial`.
///
/// The article shows one plate and names no other category. The photo prints
/// no flag. Not implemented: nothing else; no Israel-specific value exists.
abstract final class NiuePlates {
  static final PlateSpec standard = PlateSpec(
    id: 'nu.standard',
    country: NiueCountry.niue,
    canvasWidth: _Layout.width,
    canvasHeight: _Layout.height,
    panel: const PlatePanel(box: PlateBox(0, 0, 0, 0)),
    noPanel: true,
    slots: const <PlateSlot>[
      PlateSlot(
        alphabet: NiueAlphabets.digits,
        box: PlateBox(
          _Layout.digitsLeft,
          _Layout.digitCy - _Layout.digitBox / 2,
          _Layout.digitsWidth,
          _Layout.digitBox,
        ),
        length: 4,
      ),
    ],
    labels: const <PlateLabel>[
      PlateLabel(
        text: 'N\nI\nU\nE',
        box: PlateBox(_Layout.nameLeft, _Layout.nameTop, _Layout.nameWidth, _Layout.nameHeight),
        glyphHeight: _Layout.nameGlyph,
        lineHeight: _Layout.nameLineHeight,
      ),
    ],
    textGroups: const <PlateTextGroup>[
      PlateTextGroup(<int>[0], key: 'serial'),
    ],
  );

  static List<PlateSpec> get all => <PlateSpec>[standard];
}
