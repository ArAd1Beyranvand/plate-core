import 'dart:math';

import 'package:plate_alphabet/plate_alphabet.dart';
import 'package:plate_core/plate_core.dart';

import 'sint_eustatius_country.dart';

/// Where the ink sits, in plate units.
///
/// Every reference is a photograph flattened to 2080×1024 and read here at
/// 520×256 (÷4; the article's 152×300 mm is 1.97, the flattening 2.03). Spans
/// the brief's row table merges into one run were read off the flattened sheet
/// (÷1.0385 from sheet pixels).
///
/// A slot's ink is ~54% of its box height and each glyph is `0.6 × 0.72 ×
/// height` wide, so boxes are sized from the ink height and may print a run
/// wider than the photo's condensed face.
abstract final class _Layout {
  static const double width = 520, height = 256;

  /// 2007: "E" x 115–173, "30" x 342–467, ink y 62–207.
  static const double statiaBox = 150, statiaTop = 59.5;
  static const PlateBox statiaPrefix = PlateBox(104, statiaTop, 72, statiaBox);
  static const PlateBox statiaNumber = PlateBox(330, statiaTop, 160, statiaBox);
  static const PlateBox statiaCaption = PlateBox(110, 10, 300, 36);
  static const PlateBox statiaFooter = PlateBox(120, 218, 290, 22);

  /// 1976: "E191" ink x 308–377, y 33–62 (29 tall, so a 54 box); sized to
  /// 44 because a 54 box would print the run 96 wide against 69.
  static const double serialBox = 44, serialTop = 26;
  static const PlateBox serialPrefix = PlateBox(294, serialTop, 24, serialBox);
  static const PlateBox serialNumber = PlateBox(318, serialTop, 72, serialBox);

  /// "'76" ink x 290–405, y 83–157.
  static const PlateBox year = PlateBox(280, 70, 135, 100);

  /// "THE GOLDEN ROCK" ink x 237–458, y 178–207.
  static const PlateBox slogan = PlateBox(232, 173, 232, 38);

  /// "ST. EUSTATIUS N.A." stacked upright, ink x 483–499, y 20–236.
  static const PlateBox island = PlateBox(476, 14, 30, 228);
}

/// Sint Eustatius's plates (Caribbean Netherlands, 152 × 300 mm).
///
/// Groups `prefix` (the island letter) and `number`. Pair each with the theme
/// of the same name in `SintEustatiusThemes`.
///
/// Implemented: the 2007 plate ([statia]; blue, "THE HISTORIC GEM") and the
/// 1976 Bicentennial plate ([bicentennial]). Not implemented: other type
/// letters (`AB`, `BF`, `D`, `H`, `MF`, `TX`, `V`, `Z`) — the article shows no
/// St. Eustatius plate with one. Not drawn: the 2007 coat of arms and fish
/// scene and the 1976 Bicentennial logo (illustrations, no shape the spec
/// can draw). The article names nothing Israel-specific.
abstract final class SintEustatiusPlates {
  static final PlateSpec statia = _spec(
    'bq.sint_eustatius.statia',
    prefix: _field(SintEustatiusAlphabets.letters, _Layout.statiaPrefix, length: 1),
    number: _field(SintEustatiusAlphabets.digits, _Layout.statiaNumber, length: 4, minLength: 1),
    labels: const <PlateLabel>[
      PlateLabel(text: 'ST. EUSTATIUS', box: _Layout.statiaCaption, glyphHeight: 38),
      PlateLabel(text: 'THE HISTORIC GEM', box: _Layout.statiaFooter, glyphHeight: 18),
    ],
  );

  static final PlateSpec bicentennial = _spec(
    'bq.sint_eustatius.bicentennial',
    prefix: _field(SintEustatiusAlphabets.letters, _Layout.serialPrefix, length: 1),
    number: _field(SintEustatiusAlphabets.digits, _Layout.serialNumber, length: 3, minLength: 1),
    labels: <PlateLabel>[
      const PlateLabel(text: "'76", box: _Layout.year, glyphHeight: 100),
      const PlateLabel(text: 'THE GOLDEN ROCK', box: _Layout.slogan, glyphHeight: 24),
      PlateLabel(
        text: 'ST. EUSTATIUS N.A.'.split('').join('\n'),
        box: _Layout.island,
        glyphHeight: 12,
        lineHeight: 0.9,
      ),
    ],
  );

  static List<PlateSpec> get all => <PlateSpec>[statia, bicentennial];

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

  static PlateSpec _spec(
    String id, {
    required PlateSlot prefix,
    required PlateSlot number,
    List<PlateLabel> labels = const <PlateLabel>[],
  }) => PlateSpec(
    id: id,
    country: SintEustatiusCountry.sint_eustatius,
    canvasWidth: _Layout.width,
    canvasHeight: _Layout.height,
    panel: const PlatePanel(box: PlateBox(0, 0, 0, 0)),
    noPanel: true,
    slots: <PlateSlot>[prefix, number],
    labels: labels,
    textGroups: <PlateTextGroup>[
      PlateTextGroup(<int>[0], key: 'prefix'),
      PlateTextGroup(<int>[1], key: 'number'),
    ],
  );
}
