import 'dart:math';

import 'package:plate_alphabet/plate_alphabet.dart';
import 'package:plate_core/plate_core.dart';

import 'saba_island_colors.dart';
import 'saba_island_country.dart';

/// Where the ink sits, in plate units.
///
/// Canvas 520×256: the flattened photos are 2080×1024 read at ÷4 (the
/// article's 152×300 mm is 1.97, the flattening 2.03; the flattening wins).
/// The 1978 plate is `ok`-fitted: extents come from the brief's row table, the
/// "S" and "163" runs from the flattened sheet (×0.965 from sheet pixels). The
/// 2011 plate is CHECK-fitted: read off its 330×168 original and scaled by
/// 1.576 (x) and 1.524 (y).
///
/// A slot's glyph is as wide as `0.6 × 0.72 × box height`, so a box tall
/// enough for the reference ink would overrun the digit pitch. Boxes are
/// sized by the measured pitch instead and ink lands at 55–70% of the
/// reference height.
abstract final class _Layout {
  static const double width = 520, height = 256;

  /// 2011: "S" ink x 162–227, "240" x 268–458, ink y 79–186 (cy 132.5).
  /// The digit box is four pitches (50) wide; three digits sit centred.
  static const double currentBox = 146, currentCy = 132.5;
  static const PlateBox currentPrefix = PlateBox(161, 59.5, 66, currentBox);
  static const PlateBox currentNumber = PlateBox(263, 59.5, 200, currentBox);
  static const PlateBox currentSticker = PlateBox(8, 64, 44, 122);
  static const PlateBox currentCaption = PlateBox(326, 192, 180, 26);

  /// 1978: caption ink y 19.5–52.2, x 94.5–427.5; row ink y 63–193 (cy 128);
  /// "S" x 104–178, dash 191–222, "163" x 246–420 (pitch 58); footer ink
  /// y 201.5–235, x 95–427; the stacked year x 455–484.
  static const double classicBox = 134, classicCy = 128;
  static const PlateBox classicPrefix = PlateBox(101, 61, 80, classicBox);
  static const PlateBox classicDash = PlateBox(187, 61, 40, classicBox);
  static const PlateBox classicNumber = PlateBox(246, 61, 174, classicBox);
  static const PlateBox classicCaption = PlateBox(94, 14, 334, 44);
  static const PlateBox classicFooter = PlateBox(94, 196, 334, 44);
  static const PlateBox classicYear = PlateBox(450, 63, 40, 130);
}

/// Saba's plates (Caribbean Netherlands). Groups `prefix` and `number`; pair
/// each spec with the theme of the same name in `SabaIslandThemes`.
///
/// Implemented: the 2011 plate ([current]; `S`, or `R`/`D` by vehicle type)
/// and the 1978 plate ([classic1978]; `S-123`, year printed stacked at the
/// right). Not implemented: the Bonaire and St. Eustatius plates on the page
/// (`bonaire_plate`), and the 1976 St. Eustatius plate. Not drawn: the 2011
/// island silhouette and flag disc (illustrations, no shape the spec can
/// draw) and the sticker's printed text (it varies per vehicle). The 1978
/// year is stacked upright, the photo rotates it. The article names nothing
/// Israel-specific.
abstract final class SabaIslandPlates {
  static final PlateSpec current = _spec(
    'sab.current',
    prefix: _field(SabaIslandAlphabets.letters, _Layout.currentPrefix, length: 1),
    number: _field(SabaIslandAlphabets.digits, _Layout.currentNumber, length: 4, minLength: 3),
    bands: const <PlateBand>[
      PlateBand(
        box: _Layout.currentSticker,
        color: SabaIslandColors.white,
        topCornerRadius: 3,
        bottomCornerRadius: 3,
      ),
    ],
    labels: const <PlateLabel>[
      PlateLabel(text: 'SABA  THE UNSPOILED QUEEN', box: _Layout.currentCaption, glyphHeight: 16),
    ],
  );

  static final PlateSpec classic1978 = _spec(
    'sab.classic1978',
    prefix: _field(SabaIslandAlphabets.letters, _Layout.classicPrefix, length: 1),
    number: _field(SabaIslandAlphabets.digits, _Layout.classicNumber, length: 3, minLength: 1),
    labels: const <PlateLabel>[
      PlateLabel(text: 'SABA NA', box: _Layout.classicCaption, glyphHeight: 56),
      PlateLabel(text: '-', box: _Layout.classicDash, glyphHeight: 134),
      PlateLabel(text: 'UNSPOILED QUEEN', box: _Layout.classicFooter, glyphHeight: 46),
      PlateLabel(text: '1\n9\n7\n8', box: _Layout.classicYear, glyphHeight: 36, lineHeight: 0.9),
    ],
  );

  static List<PlateSpec> get all => <PlateSpec>[current, classic1978];

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
    List<PlateBand> bands = const <PlateBand>[],
    List<PlateLabel> labels = const <PlateLabel>[],
  }) => PlateSpec(
    id: id,
    country: SabaIslandCountry.saba_island,
    canvasWidth: _Layout.width,
    canvasHeight: _Layout.height,
    panel: const PlatePanel(box: PlateBox(0, 0, 0, 0)),
    noPanel: true,
    bands: bands,
    slots: <PlateSlot>[prefix, number],
    labels: labels,
    textGroups: <PlateTextGroup>[
      PlateTextGroup(<int>[0], key: 'prefix'),
      PlateTextGroup(<int>[1], key: 'number'),
    ],
  );
}
