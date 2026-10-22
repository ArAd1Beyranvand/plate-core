import 'dart:math';

import 'package:plate_alphabet/plate_alphabet.dart';
import 'package:plate_core/plate_core.dart';

import 'turks_and_caicos_islands_country.dart';

/// Where the ink sits, in plate units (the 300 × 152 mm the article gives).
///
/// Modern plate: read off `sheet_flat.png`, the 2019 photo flattened to
/// 538 × 273 px (× 0.558 to units). The photo is CHECK-fitted, so these are
/// read off pixels but not independently confirmed. Red digit runs at
/// x 92–146, 165–220, 241–294, 311–364, 383–441 px, i.e. units 51–246 (pitch
/// ~40), ink y ~25–125 (100 tall). A 100-tall ink would need a ~180 box on a
/// 152 plate with captions, so the box is 110 and the ink lands at ~60% of the
/// photo's. "BEAUTIFUL BY NATURE" spans x 58–236, y 2–15; "Turks & Caicos
/// Islands" x 35–263, y 127–152.
///
/// Prefixed plate: from the 1970s photo (CHECK, aspect 2.67 stretched to
/// 2.0): `TC` x 12–104, digits x 127–285, ink y 10.5–129. Rescaled so five
/// digits fit; the digit count is the article's "TC 1234 / TC 12345". The
/// self-drive "S D" is placed by hand, not measured.
abstract final class _Layout {
  static const double width = 300, height = 152;

  static const double modernCy = 75, modernBox = 110;
  static const double modernLeft = 40, modernWidth = 216;
  static const double topCx = 148, topCy = 8.5, topWidth = 200, topBox = 15;
  static const double topGlyph = 22;
  static const double bottomCx = 149, bottomCy = 140, bottomWidth = 240;
  static const double bottomBox = 24, bottomGlyph = 24;

  static const double prefCy = 76, prefBox = 90;
  static const double prefixLeft = 12, prefixWidth = 68;
  static const double serialLeft = 90, serialWidth = 198;
  static const double sdCx = 150, sdCy = 14, sdGlyph = 22, sdWidth = 60;
}

/// Turks and Caicos Islands's current plates.
///
/// [modern]: five digits under "BEAUTIFUL BY NATURE" and over "Turks & Caicos
/// Islands"; pair with [TurksAndCaicosIslandsThemes.privateBlack] (since
/// December 2022) or [TurksAndCaicosIslandsThemes.privateRed] (2000–2022).
/// [prefixed]: `TC` and one to five digits, for commercial (green),
/// government (black) and the 1978 private series (red).
/// [selfDrive]: [prefixed] with "S D" at the top, in yellow.
///
/// Not implemented: the 1970s white-on-black plate (historical), the taxi
/// plate (blue-white-green gradient and flamingo, no reference) and the
/// Governor's crown plate (unticked in the article). The island graphics (shell,
/// flamingo, cactus) are artwork and are left blank. The article names no
/// Israel-specific value.
abstract final class TurksAndCaicosIslandsPlates {
  static final PlateSpec modern = _spec(
    'tc.modern',
    slots: <PlateSlot>[
      PlateSlot(
        alphabet: TurksAndCaicosIslandsAlphabets.digits,
        box: PlateBox(
          _Layout.modernLeft,
          _Layout.modernCy - _Layout.modernBox / 2,
          _Layout.modernWidth,
          _Layout.modernBox,
        ),
        length: 5,
      ),
    ],
    groups: const <PlateTextGroup>[
      PlateTextGroup(<int>[0], key: 'serial'),
    ],
    labels: <PlateLabel>[
      _label(
        'BEAUTIFUL BY NATURE',
        _Layout.topCx,
        _Layout.topCy,
        _Layout.topWidth,
        _Layout.topBox,
        _Layout.topGlyph,
      ),
      _label(
        'Turks & Caicos Islands',
        _Layout.bottomCx,
        _Layout.bottomCy,
        _Layout.bottomWidth,
        _Layout.bottomBox,
        _Layout.bottomGlyph,
      ),
    ],
  );

  static final PlateSpec prefixed = _prefixed('tc.prefixed');

  static final PlateSpec selfDrive = _prefixed(
    'tc.self_drive',
    labels: <PlateLabel>[
      _label('S D', _Layout.sdCx, _Layout.sdCy, _Layout.sdWidth, _Layout.topBox, _Layout.sdGlyph),
    ],
  );

  static List<PlateSpec> get all => <PlateSpec>[modern, prefixed, selfDrive];

  static PlateSpec _prefixed(String id, {List<PlateLabel> labels = const <PlateLabel>[]}) {
    final double boxTop = _Layout.prefCy - _Layout.prefBox / 2;
    return _spec(
      id,
      slots: <PlateSlot>[
        PlateSlot(
          alphabet: TurksAndCaicosIslandsAlphabets.letters,
          box: PlateBox(_Layout.prefixLeft, boxTop, _Layout.prefixWidth, _Layout.prefBox),
          length: 2,
          spacing: max(0, _Layout.prefixWidth / 2 - 0.6 * 0.72 * _Layout.prefBox),
        ),
        PlateSlot(
          alphabet: TurksAndCaicosIslandsAlphabets.digits,
          box: PlateBox(_Layout.serialLeft, boxTop, _Layout.serialWidth, _Layout.prefBox),
          length: 5,
          minLength: 1,
        ),
      ],
      groups: const <PlateTextGroup>[
        PlateTextGroup(<int>[0], key: 'prefix'),
        PlateTextGroup(<int>[1], key: 'serial'),
      ],
      labels: labels,
    );
  }

  static PlateLabel _label(
    String text,
    double cx,
    double cy,
    double width,
    double box,
    double glyph,
  ) => PlateLabel(
    text: text,
    box: PlateBox(cx - width / 2, cy - box / 2, width, box),
    glyphHeight: glyph,
  );

  static PlateSpec _spec(
    String id, {
    required List<PlateSlot> slots,
    required List<PlateTextGroup> groups,
    List<PlateLabel> labels = const <PlateLabel>[],
  }) => PlateSpec(
    id: id,
    country: TurksAndCaicosIslandsCountry.turks_and_caicos_islands,
    canvasWidth: _Layout.width,
    canvasHeight: _Layout.height,
    panel: const PlatePanel(box: PlateBox(0, 0, 0, 0)),
    noPanel: true,
    slots: slots,
    labels: labels,
    textGroups: groups,
  );
}
