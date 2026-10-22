import 'package:plate_alphabet/plate_alphabet.dart';
import 'package:plate_core/plate_core.dart';

import 'kenya_country.dart';
import 'kenya_missions.dart';

/// Where the ink sits, in plate units.
///
/// Both references are one photograph (`New_Kenyan_license_plates.jpg`),
/// perspective-flattened to the article's sizes — 520×110 for the long plate,
/// 250×200 for the square — and projected onto each axis.
///
/// Long plate (`KDK 101A`): ink y 9.2–104 (95 tall, cy 56.6); glyph centres
/// K 99.8, D 154.9, K 210.1; 1 300.5, 0 353.7, 1 410.6, A 466.5 (pitch ~55.3).
/// Flag x 5–47, y 9–40.
///
/// Square (`KDK 102A`): letters y 7–91 (cy 49), centres 86, 144, 200 (pitch
/// 57); digits y 108–193 (cy 150.5), centres 38, 92, 146, 200 (pitch 54).
/// Flag x 10–57, y 7.5–37.5.
///
/// The reference ink is 95 tall on a 110 plate; the slot box is capped at 104,
/// which paints ink near 60% of that — the engine's `glyphStyle` is 0.72 of
/// the box and a bold cap three quarters of that. The 2022 plates' font is
/// FE-Schrift; no such face ships, so glyph widths differ from the photo.
///
/// Diplomatic: NOT measured. No photograph shows one, so the slots are an even
/// 40-unit pitch fitted to the article's `1CD1AK` format.
abstract final class _Layout {
  static const double rowWidth = 520, rowHeight = 110;
  static const double rowBox = 104, rowTop = 4.6;
  static const double rowPitch = 55.3;
  static const double rowLettersLeft = 72.1;
  static const double rowDigitsLeft = 271.85;
  static const double rowSuffixLeft = 438.75;
  static const PlateBox rowFlag = PlateBox(5, 9, 42, 28);

  static const double squareWidth = 250, squareHeight = 200;
  static const double squareBox = 96;
  static const double squareLettersTop = 1, squareDigitsTop = 102.5;
  static const double squareLettersLeft = 57.5, squareLettersPitch = 57;
  static const double squareDigitsLeft = 11, squareDigitsPitch = 54;
  static const PlateBox squareFlag = PlateBox(10, 8, 45, 30);

  static const double dipBox = 80, dipTop = 15, dipPitch = 40;
}

/// Three letters, three digits and a letter (`KDK 101A`), on one row ([row],
/// 520×110) or stacked ([square], 250×200), with a small flag decal. Colour
/// belongs to the theme, not the spec.
///
/// [diplomatic] is `1 CD 1 AK`: a mission number, `CD` or `UN`, a serial and
/// two letters, white on red. Mission `24` is Israel in the article's table and
/// is refused by [KenyaMissions.restriction].
///
/// Not implemented: the 1920–2007 formats, the 2026 `KE` series (announced, no
/// reference), motorcycle `KMCA`, `GK` government and the NGO plate.
abstract final class KenyaPlates {
  static const PlatePanel _hiddenPanel = PlatePanel(box: PlateBox(0, 0, 0, 0));

  static final PlateSpec row = _spec(
    'ke.row',
    _Layout.rowWidth,
    _Layout.rowHeight,
    flag: _Layout.rowFlag,
    slots: _registerSlots(
      box: _Layout.rowBox,
      lettersLeft: _Layout.rowLettersLeft,
      lettersPitch: _Layout.rowPitch,
      lettersTop: _Layout.rowTop,
      digitsLeft: _Layout.rowDigitsLeft,
      digitsPitch: _Layout.rowPitch,
      digitsTop: _Layout.rowTop,
      suffixLeft: _Layout.rowSuffixLeft,
    ),
  );

  static final PlateSpec square = _spec(
    'ke.square',
    _Layout.squareWidth,
    _Layout.squareHeight,
    flag: _Layout.squareFlag,
    slots: _registerSlots(
      box: _Layout.squareBox,
      lettersLeft: _Layout.squareLettersLeft,
      lettersPitch: _Layout.squareLettersPitch,
      lettersTop: _Layout.squareLettersTop,
      digitsLeft: _Layout.squareDigitsLeft,
      digitsPitch: _Layout.squareDigitsPitch,
      digitsTop: _Layout.squareDigitsTop,
      suffixLeft: _Layout.squareDigitsLeft + 3 * _Layout.squareDigitsPitch,
    ),
  );

  static final PlateSpec diplomatic = PlateSpec(
    id: 'ke.diplomatic',
    country: KenyaCountry.kenya,
    canvasWidth: _Layout.rowWidth,
    canvasHeight: _Layout.rowHeight,
    panel: _hiddenPanel,
    noPanel: true,
    slots: <PlateSlot>[
      _run(KenyaAlphabets.digits, 3, 50, minLength: 1),
      PlateSlot(
        alphabet: KenyaAlphabets.diplomaticType,
        box: const PlateBox(176, _Layout.dipTop, 88, _Layout.dipBox),
      ),
      _run(KenyaAlphabets.digits, 3, 276, minLength: 1),
      _run(KenyaAlphabets.letters, 2, 406),
    ],
    textGroups: const <PlateTextGroup>[
      PlateTextGroup(<int>[0], key: 'mission'),
      PlateTextGroup(<int>[1], key: 'type', prefix: ' '),
      PlateTextGroup(<int>[2], key: 'digits', prefix: ' '),
      PlateTextGroup(<int>[3], key: 'letters'),
    ],
    restrictions: const <PlateRestriction>[KenyaMissions.restriction],
  );

  static List<PlateSpec> get all => <PlateSpec>[row, square, diplomatic];

  /// A variable-length run printed at the diplomatic pitch.
  static PlateSlot _run(PlateAlphabet alphabet, int length, double left, {int? minLength}) =>
      PlateSlot(
        alphabet: alphabet,
        box: PlateBox(left, _Layout.dipTop, length * _Layout.dipPitch, _Layout.dipBox),
        length: length,
        minLength: minLength,
        spacing: _Layout.dipPitch - 0.6 * 0.72 * _Layout.dipBox,
      );

  /// Three letters, three digits, then a suffix letter at the digits' pitch.
  static List<PlateSlot> _registerSlots({
    required double box,
    required double lettersLeft,
    required double lettersPitch,
    required double lettersTop,
    required double digitsLeft,
    required double digitsPitch,
    required double digitsTop,
    required double suffixLeft,
  }) => <PlateSlot>[
    ..._across(KenyaAlphabets.letters, 3, lettersLeft, lettersPitch, lettersTop, box),
    ..._across(KenyaAlphabets.digits, 3, digitsLeft, digitsPitch, digitsTop, box),
    ..._across(KenyaAlphabets.letters, 1, suffixLeft, digitsPitch, digitsTop, box),
  ];

  static List<PlateSlot> _across(
    PlateAlphabet alphabet,
    int count,
    double left,
    double pitch,
    double top,
    double height,
  ) => plateRegisterAcross(
    alphabet: alphabet,
    count: count,
    left: left,
    right: left + count * pitch,
    top: top,
    height: height,
  );

  static PlateSpec _spec(
    String id,
    double width,
    double height, {
    required PlateBox flag,
    required List<PlateSlot> slots,
  }) => PlateSpec(
    id: id,
    country: KenyaCountry.kenya,
    canvasWidth: width,
    canvasHeight: height,
    panel: _hiddenPanel,
    noPanel: true,
    decals: <PlateDecal>[PlateDecal(drawing: KenyaCountry.flag, box: flag)],
    slots: slots,
    textGroups: const <PlateTextGroup>[
      PlateTextGroup(<int>[0, 1, 2], key: 'letters'),
      PlateTextGroup(<int>[3, 4, 5], key: 'digits', prefix: ' '),
      PlateTextGroup(<int>[6], key: 'suffix'),
    ],
  );
}
