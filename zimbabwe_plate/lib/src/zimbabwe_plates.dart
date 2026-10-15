import 'dart:math';

import 'package:plate_alphabet/plate_alphabet.dart';
import 'package:plate_core/plate_core.dart';

import 'zimbabwe_country.dart';
import 'zimbabwe_themes.dart';

/// Where the ink sits, in plate units.
///
/// Both references are photographs, flattened to 520×110 (the British size the
/// article cites) and projected onto each axis. The single-row plate fits
/// confidently; the stacked plate is CHECK-fitted and was flattened to the same
/// 520×110 although the plate is 1.58 wide, so its numbers are rescaled below
/// to a 340×215 canvas (x × 0.654, y × 1.955).
///
/// Single row (`Zimbabwe_car_plate`): ink y 7.5–93 (85.5 tall, cy 50.25);
/// letters centred 60.1, 119.0, 177.9 (pitch 58.9); crest x 210–246; digits
/// from 299.5 at about 56, ending 488.2.
///
/// Stacked (`Zimbabwe_license_plate_square`), before rescaling: letters
/// y 7.5–55 centred 193.3, 299.5, 404.2; digits y 58.2–102.2 centred 146.5,
/// 248.3, 347, 442.
///
/// The reference ink is 85.5 tall on a 110 plate; a box that tall would need a
/// ~155-unit slot, so the box is capped at the canvas and the ink lands near
/// 60% of the photo's. The crest between letters and digits is a coat of arms
/// and is left blank: it is no shape the spec can draw and no asset ships.
abstract final class _Layout {
  static const double rowWidth = 520, rowHeight = 110;
  static const double rowCy = 50.25, rowBox = 96;
  static const double letterCx = 60.1, letterPitch = 58.9;
  static const double digitCx = 299.5, digitPitch = 56;

  static const double stackWidth = 340, stackHeight = 215;
  static const double stackBox = 100;
  static const double stackLetterCy = 61.1, stackLetterCx = 126.4;
  static const double stackLetterPitch = 69;
  static const double stackDigitCy = 156.8, stackDigitCx = 95.8;
  static const double stackDigitPitch = 64.4;
}

/// Zimbabwe's current plates: three letters and four digits, on one row or
/// stacked. Groups `letters`, `serial`. Colour is the theme's: pair [row] with
/// [ZimbabweThemes.yellow], [ZimbabweThemes.white] or
/// [ZimbabweThemes.commercial], and [stacked] with
/// [ZimbabweThemes.yellowStacked].
///
/// Not implemented: the 1971–2006 formats and the military plate (white on
/// black, `123 AB 81`), for which no reference was measured. The article names
/// no Israel-specific value.
abstract final class ZimbabwePlates {
  static final PlateSpec row = _spec(
    'zw.row',
    _Layout.rowWidth,
    _Layout.rowHeight,
    letters: _slots(
      ZimbabweAlphabets.letters,
      3,
      _Layout.letterCx,
      _Layout.letterPitch,
      _Layout.rowCy,
      _Layout.rowBox,
    ),
    serial: _slots(
      ZimbabweAlphabets.digits,
      4,
      _Layout.digitCx,
      _Layout.digitPitch,
      _Layout.rowCy,
      _Layout.rowBox,
    ),
  );

  static final PlateSpec stacked = _spec(
    'zw.stacked',
    _Layout.stackWidth,
    _Layout.stackHeight,
    letters: _slots(
      ZimbabweAlphabets.letters,
      3,
      _Layout.stackLetterCx,
      _Layout.stackLetterPitch,
      _Layout.stackLetterCy,
      _Layout.stackBox,
    ),
    serial: _slots(
      ZimbabweAlphabets.digits,
      4,
      _Layout.stackDigitCx,
      _Layout.stackDigitPitch,
      _Layout.stackDigitCy,
      _Layout.stackBox,
    ),
  );

  static List<PlateSpec> get all => <PlateSpec>[row, stacked];

  static PlateSlot _slots(
    PlateAlphabet alphabet,
    int count,
    double firstCx,
    double pitch,
    double cy,
    double box,
  ) => PlateSlot(
    alphabet: alphabet,
    box: PlateBox(firstCx - pitch / 2, cy - box / 2, count * pitch, box),
    length: count,
    spacing: max(0, pitch - 0.6 * 0.72 * box),
  );

  static PlateSpec _spec(
    String id,
    double width,
    double height, {
    required PlateSlot letters,
    required PlateSlot serial,
  }) => PlateSpec(
    id: id,
    country: ZimbabweCountry.zimbabwe,
    canvasWidth: width,
    canvasHeight: height,
    panel: const PlatePanel(box: PlateBox(0, 0, 0, 0)),
    noPanel: true,
    slots: <PlateSlot>[letters, serial],
    textGroups: <PlateTextGroup>[
      PlateTextGroup(<int>[0], key: 'letters'),
      PlateTextGroup(<int>[1], key: 'serial'),
    ],
  );
}
