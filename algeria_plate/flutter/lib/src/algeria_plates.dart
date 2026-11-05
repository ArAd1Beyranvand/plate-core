import 'package:flutter/widgets.dart';
import 'package:plate_core/plate_core.dart';

import 'algeria_alphabets.dart';
import 'algeria_country.dart';
import 'algeria_regions.dart';

/// Where the ink sits on an Algerian plate, in millimetres.
///
/// The article gives 520×110 (455–520 × 100–110 allowed). The single-line
/// figures are off the front/rear artwork, its black rim's outer edge
/// (978×209 px, aspect 4.68 against the documented 4.73) mapped to 520×110:
///
/// * Ink rows y 19.2..86.3 (front) and 20.4..88.0 (rear): 67 mm tall,
///   centred at ~53.5.
/// * Glyph centres 31.7 78.2 126.0 171.2 217.5 | 280.5 319.9 366.6 |
///   434.7 482.8. A least-squares fit of left, pitch and group gap (the
///   proportional `1` left out) gives pitch 45.6 and an extra 18.0 between
///   groups, residuals ≤ 5. The run is centred: 14 + 10·45.6 + 2·18 + 14.
/// * The army photo (silver rim 52..530 × 38..2406 px mapped to 520×110):
///   nine digits, centres 129.6 … 471.8, pitch 42.8, ink 13..97; the round
///   flag at x 47.4..104.0, y ~31..91.
///
/// **Under-height ink, accepted.** The regulation asks for 75 mm digits and
/// the artwork draws 67; 67 would need a ~128 mm slot on a 110 mm plate
/// (`glyphStyle` sets 0.72 of the slot, a bold digit is ~0.73 of that). The
/// slots are as tall as the plate allows, and the glyph is then
/// width-limited by its 45.6 mm cell, since DejaVu Bold's digits are far
/// wider than the plate's condensed face. `plate_core` is unchanged.
///
/// **Fields, not cells.** Each group is one `PlateSlot` run spanning its
/// cells; `spacing` brings the font's advance up to the measured pitch. The
/// regulation's narrow 20 mm `1` is not modelled.
abstract final class _Layout {
  static const double width = 520, height = 110, slotTop = 2, slotHeight = 104;
  static const double left = 14, pitch = 45.6, groupGap = 18;

  // Two-line, 275×200, from the article's regulation text alone — no image.
  // Digits 30 wide with 10 between them: pitch 40. Two 75 mm rows with equal
  // air around them centre at 54.2 and 145.8. The group gap is the
  // single-line one scaled to the pitch.
  static const double twoWidth = 275, twoHeight = 200, twoPitch = 40;
  static const double twoGap = 16, twoSlotHeight = 92;
  static const double twoRow1Top = 54.2 - twoSlotHeight / 2;
  static const double twoRow2Top = 145.8 - twoSlotHeight / 2;

  // Diplomatic NNN-NN-NN: no image exists on the page, so this is the
  // single-line digit cell with two hyphen cells, centred. Unmeasured.
  static const double hyphenWidth = 30;

  /// A label is not shrunk to its box: this prints a ~15 mm dash.
  static const double hyphenGlyph = 58;

  // Army.
  static const double armyLeft = 108.2, armyPitch = 42.8, armySlotTop = 3;
  static const double roundelLeft = 46.7, roundelTop = 31, roundelSize = 58;
}

/// Algeria's plate geometries. Front and rear singleLine plates share a spec;
/// the livery is the theme's.
///
/// The civil specs have one field per text group: `serial` (5), `type` (3:
/// vehicle class then year of manufacture) and `wilaya` (2); diplomatic has
/// `serial` (1–3), `status` (2) and `mission` (2); army has `serial` (9).
///
/// Not implemented: the 140×120 motorcycle plate. The article gives 26 mm
/// digits with "the rest the same", i.e. 10 mm between them, which cannot
/// put five digits on a 140 mm row.
abstract final class AlgeriaPlates {
  static const PlateAlphabet _digits = AlgeriaAlphabets.digits;

  /// Serial, vehicle type and wilaya, for the civil plates.
  static const List<PlateRowRun> _serial = [
    PlateRowRun(_digits, 5, group: 'serial'),
  ];
  static const List<PlateRowRun> _typeWilaya = [
    PlateRowRun(_digits, 3, group: 'type'),
    PlateRowRun(_digits, 2, group: 'wilaya'),
  ];

  static final PlateSpec singleLine = PlateSpec(
    id: 'dz.singleLine',
    country: AlgeriaCountry.algeria,
    canvasWidth: _Layout.width,
    canvasHeight: _Layout.height,
    noPanel: true,
    panel: const PlatePanel(box: PlateBox(0, 0, 0, _Layout.height)),
    slots: plateRow(
      [..._serial, ..._typeWilaya],
      left: _Layout.left,
      top: _Layout.slotTop,
      height: _Layout.slotHeight,
      pitch: _Layout.pitch,
      gap: _Layout.groupGap,
    ).slots,
    resolveRegion: AlgeriaRegions.captionOf,
  );

  static final PlateSpec twoLine = () {
    PlateRowLayout row(List<PlateRowItem> items, double top) => plateRow(
      items,
      centre: _Layout.twoWidth / 2,
      top: top,
      height: _Layout.twoSlotHeight,
      pitch: _Layout.twoPitch,
      gap: _Layout.twoGap,
    );
    return PlateSpec(
      id: 'dz.twoLine',
      country: AlgeriaCountry.algeria,
      canvasWidth: _Layout.twoWidth,
      canvasHeight: _Layout.twoHeight,
      // The theme's rim ratio is of a 110 mm height; keep the rim 4.3 mm.
      borderWidthRatioOverride: 4.3 / _Layout.twoHeight,
      noPanel: true,
      panel: const PlatePanel(box: PlateBox(0, 0, 0, _Layout.twoHeight)),
      slots: [
        ...row(_serial, _Layout.twoRow1Top).slots,
        ...row(_typeWilaya, _Layout.twoRow2Top).slots,
      ],
      resolveRegion: AlgeriaRegions.captionOf,
    );
  }();

  static final PlateSpec diplomatic = () {
    const hyphen = PlateRowText.styled(
      '-',
      _Layout.hyphenWidth,
      glyphHeight: _Layout.hyphenGlyph,
    );
    final row = plateRow(
      const [
        PlateRowRun(_digits, 3, group: 'serial', minLength: 1),
        hyphen,
        PlateRowRun(_digits, 2, group: 'status'),
        hyphen,
        PlateRowRun(_digits, 2, group: 'mission'),
      ],
      centre: _Layout.width / 2,
      top: _Layout.slotTop,
      height: _Layout.slotHeight,
      pitch: _Layout.pitch,
    );
    return PlateSpec(
      id: 'dz.diplomatic',
      country: AlgeriaCountry.algeria,
      canvasWidth: _Layout.width,
      canvasHeight: _Layout.height,
      noPanel: true,
      panel: const PlatePanel(box: PlateBox(0, 0, 0, _Layout.height)),
      slots: row.slots,
      labels: row.labels,
    );
  }();

  static final PlateSpec army = PlateSpec(
    id: 'dz.army',
    country: AlgeriaCountry.algeria,
    canvasWidth: _Layout.width,
    canvasHeight: _Layout.height,
    noPanel: true,
    panel: const PlatePanel(box: PlateBox(0, 0, 0, _Layout.height)),
    slots: [
      plateRun(
        _digits,
        9,
        left: _Layout.armyLeft,
        top: _Layout.armySlotTop,
        pitch: _Layout.armyPitch,
        height: _Layout.slotHeight,
        group: 'serial',
      ),
    ],
    decals: const <PlateDecal>[
      PlateDecal(
        image: AssetImage('assets/dz_roundel.png', package: 'algeria_plate'),
        box: PlateBox(
          _Layout.roundelLeft,
          _Layout.roundelTop,
          _Layout.roundelSize,
          _Layout.roundelSize,
        ),
      ),
    ],
  );
}
