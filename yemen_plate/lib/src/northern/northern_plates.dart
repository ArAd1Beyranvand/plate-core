import 'package:plate_core/plate_core.dart';
import 'package:flutter/widgets.dart';

import '../common/yemen_alphabets.dart';
import '../common/yemen_country.dart';

/// System B — the 1993 format, still the larger share of the fleet. A top band
/// (اليمن + usage word) over a left/right split (governorate code + serial).
/// Colour-coded by usage (blue/yellow/red/green/black for private/hire/transport/govt/military);
/// colour lives in [YemenThemes], not here. Governorate is one field of 1–2 digits,
/// serial one field of 4–6 ([PlateSlot.minLength] .. length).
abstract final class YemenNorthernPlates {
  // ---------------------------------------------------------------------------
  // Shared geometry.
  // ---------------------------------------------------------------------------

  // 540 x 288 (aspect 1.875) measured from an issued blue private plate.
  // Coordinates below are measured fractions multiplied out; comments give fraction, code gives units.
  static const double _carWidth = 540;
  static const double _height = 288;
  static const double _motoWidth = 289; // CALIBRATE: no photo available
  static const double _borderRatio = 0.035; // CALIBRATE: matches theme ratio

  // Car: top band, full-width rule, then one row split by vertical divider
  // (governorate left, serial right), measured off photograph:
  //   top band     y 0.038 .. 0.219
  //   rule         y 0.289 .. 0.314   full width
  //   divider      x 0.246 .. 0.260   from rule bottom to frame
  //   governorate  x 0.006 .. 0.246   y 0.331 .. 0.641
  //   serial       x 0.260 .. 0.983   y 0.331 .. 0.641
  //
  // Single row split by divider (not stacked). Big arabic row with small Latin
  // mirrors below (one value in two scripts, editable in both).

  /// اليمن on the left (x 0.076 .. 0.231). Separate label (not joined to usage word
  /// to keep bidi isolated). Box is wider than measured text and centred on it
  /// to account for platform font fallback width. Dash is its own label (not appended).
  static const List<PlateLabel> _carLabels = <PlateLabel>[];

  /// Usage word as the country panel caption (full width, x 0.027 .. 0.987,
  /// y 0.038 .. 0.219). Panel is transparent; the word prints on the field.
  /// captionScale fits down only, never up, so scale must size for fit to bind.
  static const PlatePanel _carPanel = PlatePanel(
    box: PlateBox(0, 6, 540, 62),
    flagScale: 0, // No flag on a Yemeni plate
    captionScale: 4.5,
    padding: EdgeInsets.fromLTRB(50, 3, 50, 0),
  );

  // Full-width divider under the top band (y 0.289 .. 0.314: 83 .. 90), then a
  // vertical one between governorate and serial cells (x 0.246 .. 0.260:
  // 133 .. 140) from that divider down to the frame. Same for every car
  // layout regardless of digit counts.
  static const PlateSection _carBackground = PlateSection.rows(<PlatePart>[
    PlatePart(PlateSection.plain, end: 86.5, divider: 7),
    PlatePart(
      PlateSection.columns(<PlatePart>[
        PlatePart(PlateSection.plain, end: 136.5, divider: 7),
        PlatePart(PlateSection.plain),
      ]),
    ),
  ]);

  // The governorate field: x 0.006 .. 0.246 of the plate, one or two digits
  // at the same 89-unit cap height as the serial beside it — the photograph
  // shows one row. Codes run 1..22; `YemenNorthernValidator` rejects the rest.
  //
  // On turning a measured cap height into a cell height: core sets a glyph at
  // `0.72 * cellHeight` and names no font family, so these render in Roboto,
  // whose cap is 0.711 em. This package cannot supply the plate's own square
  // Kufic — see the README's `## Fonts`.
  static const PlateSlot _carGovernorate = PlateSlot(
    alphabet: YemenAlphabets.iranianDigits,
    box: PlateBox(24, 95, 88, 89),
    length: 2,
    minLength: 1,
  );

  // The serial field: x 0.260 .. 0.983 of the plate (140 .. 530), four to six
  // digits centred in the span.
  static const PlateSlot _carSerial = PlateSlot(
    alphabet: YemenAlphabets.iranianDigits,
    box: PlateBox(140, 95, 390, 89),
    length: 6,
    minLength: 4,
  );

  // Small Latin echo row (y 0.697 .. 0.882, cap 0.185 = 53 units, box 104 units).
  // Box is deeper than cap to prevent clipping. Each mirror takes its source's
  // x/width and is editable: one value in two scripts.
  static const double _echoTop = 175;
  static const double _echoHeight = 104;

  static const List<PlateMirror> _carMirrors = <PlateMirror>[
    PlateMirror(
      source: 0,
      box: PlateBox(24, _echoTop, 88, _echoHeight),
      glyphHeight: _echoHeight,
      alphabet: YemenAlphabets.digits,
      editable: true,
    ),
    PlateMirror(
      source: 1,
      box: PlateBox(140, _echoTop, 390, _echoHeight),
      glyphHeight: _echoHeight,
      alphabet: YemenAlphabets.digits,
      editable: true,
    ),
  ];

  // Motorcycle: row-and-divider structure from car, widths compressed to square canvas.
  // No photo available; x values are car's ratios renormalised, y values unchanged.
  // Vertical layout carries across 1:1 (both canvases 288 tall).

  // اليمن keeping 1 : 2.41 width ratio against usage word. Glyph height 42 (not 62)
  // to prevent clipping on the narrower canvas.
  static const List<PlateLabel> _motoLabels = <PlateLabel>[];

  static const PlatePanel _motoPanel = PlatePanel(
    box: PlateBox(0, 6, 289, 62),
    flagScale: 0,
    captionScale: 4.5,
    padding: EdgeInsets.fromLTRB(25, 3, 25, 0),
  );

  // Same row-and-divider structure as the car, renormalised onto the
  // narrower canvas: full-width rule under the top band, then one vertical
  // divider splitting a governorate cell (left) from a five-digit serial
  // cell (right) — no second horizontal rule inside the row.
  static const PlateSection _motoBackground = PlateSection.rows(<PlatePart>[
    PlatePart(PlateSection.plain, end: 86.5, divider: 7),
    PlatePart(
      PlateSection.columns(<PlatePart>[
        PlatePart(PlateSection.plain, end: 73, divider: 4),
        PlatePart(PlateSection.plain),
      ]),
    ),
  ]);

  static const PlateSlot _motoGovernorate = PlateSlot(
    alphabet: YemenAlphabets.iranianDigits,
    box: PlateBox(13, 95, 48, 89),
    length: 2,
    minLength: 1,
  );

  static const PlateSlot _motoSerial = PlateSlot(
    alphabet: YemenAlphabets.iranianDigits,
    box: PlateBox(75, 95, 209, 89),
    length: 6,
    minLength: 4,
  );

  /// The small Latin echo row: the car's band, each mirror under its source.
  /// The glyph is 56 rather than 104 because the narrow governorate field would
  /// clip a larger one. Derived, not measured.
  static const double _motoEchoHeight = 56;

  static const List<PlateMirror> _motoMirrors = <PlateMirror>[
    PlateMirror(
      source: 0,
      box: PlateBox(13, _echoTop, 48, _echoHeight),
      glyphHeight: _motoEchoHeight,
      alphabet: YemenAlphabets.digits,
      editable: true,
    ),
    PlateMirror(
      source: 1,
      box: PlateBox(75, _echoTop, 209, _echoHeight),
      glyphHeight: _motoEchoHeight,
      alphabet: YemenAlphabets.digits,
      editable: true,
    ),
  ];

  // --- Text groups. ---------------------------------------------------------

  static const List<PlateTextGroup> _groups = <PlateTextGroup>[
    PlateTextGroup(<int>[0], key: 'governorate'),
    PlateTextGroup(<int>[1], key: 'serial'),
  ];

  // ---------------------------------------------------------------------------
  // Car plate.
  //
  // **Usage is not a field of a spec.** It selects the country block (which
  // carries the usage word) and the theme (which carries the field colour), and
  // both are render-time inputs on `PlateCanvas`:
  //
  // ```dart
  // PlateCanvas(
  //   spec: YemenNorthernPlates.car,
  //   country: YemenCountry.northernFor(usage),
  //   theme: YemenThemes.forNorthernUsage(usage),
  // )
  // ```
  //
  // Each spec names `YemenCountry.northernPrivate` as its own `country`, so a
  // caller that passes no override gets the ordinary case rather than a blank
  // top band. `PlateSpec.country` is a default, not a claim about the vehicle.
  // ---------------------------------------------------------------------------

  /// The car plate.
  static final PlateSpec car = PlateSpec(
    id: 'ye.northern.car',
    country: YemenCountry.northernPrivate,
    canvasWidth: _carWidth,
    canvasHeight: _height,
    panel: _carPanel,
    slots: const <PlateSlot>[_carGovernorate, _carSerial],
    mirrors: _carMirrors,
    background: _carBackground,
    labels: _carLabels,
    textGroups: _groups,
    borderWidthRatioOverride: _borderRatio,
  );

  // ---------------------------------------------------------------------------
  // Motorcycle plates — unverified.
  //
  // No official motorcycle design has been published for the northern system,
  // despite active registration campaigns run by the Sanaa traffic police under
  // Cabinet Decision No. 33 of 1446 AH and an equivalent process in Taiz. What
  // follows is the car's content rendered into the motorcycle form factor: the
  // same content, the same stacking, half the width. It is a reasonable guess
  // and it is a guess, so it is deprecated — not because it is going away, but
  // so that nothing silently trusts it and so it shows up in a grep.
  //
  // One colour note that does not generalise: Marib classifies motorcycles as
  // yellow. Other southern governorates publish no motorcycle colour, and
  // extrapolating Marib's rule to them would be inventing policy.
  // ---------------------------------------------------------------------------

  /// The motorcycle plate.
  @Deprecated('unverified geometry — calibrate against photographs')
  static final PlateSpec moto = PlateSpec(
    id: 'ye.northern.moto',
    country: YemenCountry.northernPrivate,
    canvasWidth: _motoWidth,
    canvasHeight: _height,
    panel: _motoPanel,
    slots: const <PlateSlot>[_motoGovernorate, _motoSerial],
    mirrors: _motoMirrors,
    background: _motoBackground,
    labels: _motoLabels,
    textGroups: _groups,
    borderWidthRatioOverride: _borderRatio,
  );
}
