import 'dart:math';

import 'package:plate_alphabet/plate_alphabet.dart';
import 'package:plate_core/plate_core.dart';

import 'sint_maarten_colors.dart';
import 'sint_maarten_country.dart';

/// Where the ink sits, in plate units (520×263, the article's 152×300 mm).
///
/// The brief's flattening used the infobox's 520×110 and is unusable for
/// geometry, so everything is read by hand off the 330×173 original of the
/// 2005 plate (plate edge ≈ x4–326, y4–168), scaled by 1.615 (x) and 1.59 (y).
/// Original ink: "P" x30–62, "2404" x141–308, both y55–138; caption
/// x87–226 y11–29; web address x92–246 y143–158.
///
/// A slot's glyph is as wide as `0.6 × 0.72 × box`, so a box as tall as the
/// 132-unit ink would overrun the row; [rowBox] is sized by the digit pitch
/// and ink lands at roughly 60–70% of the reference height.
abstract final class _Layout {
  static const double width = 520, height = 263;

  static const double rowBox = 150;
  static const double rowCy = 147; // ink y 81–213

  static const PlateBox prefix = PlateBox(36, rowCy - rowBox / 2, 64, rowBox);
  static const PlateBox number = PlateBox(221, rowCy - rowBox / 2, 270, rowBox);

  static const PlateBox caption = PlateBox(134, 11, 224, 29); // y11–40
  static const PlateBox website = PlateBox(142, 221, 249, 24); // y221–245
}

/// Sint Maarten's current plate (North American 152 × 300 mm).
///
/// Groups `prefix` and `number`. Pair with `SintMaartenThemes.private`.
///
/// Implemented: the 2005 graphic plate, which carries every type (`V`
/// commercial, `TX` taxi, `D` government, `AB` bus, `P`, `M`): they differ only
/// in the prefix letters. Not drawn: the beach photograph, the island outline
/// and the coat of arms (illustrations, no shape the spec can draw). The
/// article names nothing Israel-specific.
abstract final class SintMaartenPlates {
  static final PlateSpec private = PlateSpec(
    id: 'sx.private',
    country: SintMaartenCountry.sint_maarten,
    canvasWidth: _Layout.width,
    canvasHeight: _Layout.height,
    panel: const PlatePanel(box: PlateBox(0, 0, 0, 0)),
    noPanel: true,
    slots: <PlateSlot>[
      _field(SintMaartenAlphabets.letters, _Layout.prefix, length: 2, minLength: 1),
      _field(SintMaartenAlphabets.digits, _Layout.number, length: 4, minLength: 1),
    ],
    labels: const <PlateLabel>[
      PlateLabel(
        text: 'THE FRIENDLY ISLAND',
        box: _Layout.caption,
        glyphHeight: 30,
        color: SintMaartenColors.caption,
      ),
      PlateLabel(
        text: 'WWW.ST-MAARTEN.COM',
        box: _Layout.website,
        glyphHeight: 24,
        color: SintMaartenColors.caption,
      ),
    ],
    textGroups: <PlateTextGroup>[
      PlateTextGroup(<int>[0], key: 'prefix'),
      PlateTextGroup(<int>[1], key: 'number'),
    ],
  );

  static List<PlateSpec> get all => <PlateSpec>[private];

  /// One run of characters, printed and typed as a unit. Fixed pitch is
  /// `box.width / length`, so the glyph advance matches it.
  static PlateSlot _field(
    PlateAlphabet alphabet,
    PlateBox box, {
    required int length,
    int? minLength,
  }) => PlateSlot(
    alphabet: alphabet,
    box: box,
    length: length,
    minLength: minLength,
    spacing: max(0, box.width / length - 0.6 * 0.72 * box.height),
  );
}
